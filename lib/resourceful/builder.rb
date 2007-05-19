require 'response'
require 'resourceful/default/actions'

module Resourceful
  class Builder
    def initialize(controller_klass, &block)
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

      kontroler.read_inheritable_attribute(:resourceful_callbacks).merge! @callbacks
      kontroler.read_inheritable_attribute(:resourceful_responses).merge! @responses
    end
      
    def build(*available_actions)
      available_actions.each { |action| @ok_actions << action.to_sym }
    end

    def before(action, &block)
      @callbacks["before_#{action}".intern] = block
    end

    def after(action, &block)
      @callbacks["after_#{action}".intern] = block
    end

    def response_for(action, &block)
      if block.arity == 0
        response_for(action) do |format|
          format.html(&block)
        end
      else
        response = Response.new
        block.call response
        @responses[action.to_sym] = response.formats
      end
    end

    DEFAULT_FORMAT_RENDERS = {
      :html => Proc.new {}, # This does automatically render the right thing, right?
      :xml => Proc.new { render :xml => current_object.to_xml },
      :json => Proc.new { render :json => current_object.to_json },
      :yaml => Proc.new { render :yaml => current_object.to_yaml }
    }

    def publish(*types)
      options = (Hash === types[-1] ? types[-1] : {})
      actions = (options[:only] || [:show, :index]) - (options[:except] || [])
      actions.each do |action|
        response_for action do |format|
          types.each do |type|
            format.send(type, &DEFAULT_FORMAT_RENDERS[type])
          end
        end
      end
    end
  end
end
