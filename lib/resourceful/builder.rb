require 'resourceful/response'
require 'resourceful/serialize'
require 'resourceful/default/actions'

module Resourceful
  class Builder
    @@formats = []
    attr :controller, true

    def self.register_format(name, &block)
      @@formats.push([name, block]) unless @@formats.find{|n,b| n == name}
    end

    def initialize(kontroller)
      @controller       = kontroller
      @action_module    = Resourceful::Default::Actions.dup
      @ok_actions       = []
      @callbacks        = {:before => {}, :after => {}}
      @responses        = {}
      @parents          = []
    end

    def apply# :nodoc:
      kontroller = @controller
      Resourceful::ACTIONS.each do |action_named|
        # See if this is a method listed by build/n
        unless @ok_actions.include? action_named
          # If its not listed, then remove the method
          # No one can hit it... if its DEAD!
          @action_module.send :remove_method, action_named
        end
      end

      kontroller.hidden_actions.reject! &@ok_actions.method(:include?)
      kontroller.send :include, @action_module

      kontroller.read_inheritable_attribute(:resourceful_callbacks).merge! @callbacks
      kontroller.read_inheritable_attribute(:resourceful_responses).merge! @responses

      kontroller.write_inheritable_attribute(:parents, @parents)
      kontroller.before_filter { |c| c.send(:load_parent_objects) }
    end
      
    def actions(*available_actions)
      if available_actions.first == :all
        available_actions = controller.new.plural? ? ACTIONS : SINGULAR_ACTIONS
      end

      available_actions.each { |action| @ok_actions << action.to_sym }
    end
    alias build actions

    def before(*actions, &block)
      actions.each do |action|
        @callbacks[:before][action.to_sym] = block
      end
    end

    def after(*actions, &block)
      actions.each do |action|
        @callbacks[:after][action.to_sym] = block
      end
    end

    def response_for(*actions, &block)
      if block.arity < 1
        response_for(*actions) do |format|
          format.html(&block)
        end
      else
        response = Response.new
        block.call response

        actions.each do |action|
          @responses[action.to_sym] = response.formats
        end
      end
    end

    def publish(*types)
      options = { :only => [:show, :index] }.merge(Hash === types.last ? types.pop : {})
      actions = options[:only]
      
      actions.each do |action|
        response_for action do |format|
          types.each do |type|
            format.send(type) do
              render_action = [:json, :xml].include?(type) ? type : :text
              render render_action => current_object.serialize(type, options)
            end
          end
        end
      end
    end

    def belongs_to(*parents)
      @parents = parents.map(&:to_s)
    end
  end
end
