require 'resourceful/response'
require 'resourceful/default/actions'

module Resourceful
  class Builder
    @@formats = {}

    def self.register_format(name, &block)
      @@formats[name] = block
    end

    def initialize
      @action_module    = Resourceful::Default::Actions.dup
      @ok_actions       = []
      @callbacks        = {}
      @responses        = {}
    end

    def apply(kontroller) # :nodoc:
      Resourceful::ACTIONS.each do |action_named|
        unless @ok_actions.include? action_named
          @action_module.send :remove_method, action_named
        end
      end

      kontroller.hidden_actions.reject! &@ok_actions.method(:include?)
      kontroller.send :include, @action_module

      kontroller.read_inheritable_attribute(:resourceful_callbacks).merge! @callbacks
      kontroller.read_inheritable_attribute(:resourceful_responses).merge! @responses
    end
      
    def build(*available_actions)
      available_actions = ACTIONS if available_actions.first == :all
      available_actions.each { |action| @ok_actions << action.to_sym }
    end

    def before(action, &block)
      @callbacks["before_#{action}".intern] = block
    end

    def after(action, &block)
      @callbacks["after_#{action}".intern] = block
    end

    def response_for(action, &block)
      if block.arity < 1
        response_for(action) do |format|
          format.html(&block)
        end
      else
        response = Response.new
        block.call response
        @responses[action.to_sym] = response.formats
      end
    end

    def publish(*types)
      options = (Hash === types[-1] ? types[-1] : {})
      if options[:attribute]
        options[:attributes] = Array(options.delete(:attribute))
      end
      actions = (options.delete(:only) || [:show, :index]) - (options.delete(:except) || [])

      actions.each do |action|
        response_for action do |format|
          types.each do |type|
            format.send(type, &@@formats[type].to_proc(options))
          end
        end
      end
    end
  end
end
