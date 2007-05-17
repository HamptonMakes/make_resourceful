
require 'resourceful/default/actions'

module Resourceful
  class Builder
    def initialize(controller_klass, &block)
      @action_module    = Resourceful::Default::Actions.dup
      @ok_actions       = []
      @callbacks        = {}
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
    end
      
    def build(*available_actions)
      available_actions.each { |action| build_action action }
    end

    def before(action, &block)
      @callbacks["before_#{action}".intern] = block
    end

    def after(action, &block)
      @callbacks["after_#{action}".intern] = block
    end
    
    private  # Keep this shit on the downlow, yo!

    def build_action(named)
      @ok_actions << named.to_sym
    end
  end
end
