
require 'resourceful/default/actions'

module Resourceful

  class Builder

    def initialize(controller_klass, &block)
      @controller_klass = controller_klass
      @action_module    = Resourceful::Default::Actions.dup
      @ok_actions       = []
      
      self.instance_eval &block
      
      Resourceful::ACTIONS.each do |action_named|
        unless @ok_actions.include? action_named
          @action_module.send :remove_method, action_named
        end
      end
      
<<<<<<< .mine
      def build(*available_actions)
        available_actions.each { |available_action| build_action(available_action)}
      end

      def before(action, &block)
        callback_name = "before_#{action}".to_sym
        if is_defined? callback_name
          undef callback_name
        end
        define_method callback_name, &block
        protected callback_name
      end
     
     private  # Keep this shit on the downlow, yo!

      def build_action(named)
        @ok_actions << named.to_sym
      end

=======
      @controller_klass.hidden_actions.reject! &@ok_actions.method(:include?)
      @controller_klass.send :include, @action_module
>>>>>>> .r16
    end
    
    def build(*available_actions)
      available_actions.each { |available_action| build_action(available_action)}
    end
    
    private  # Keep this shit on the downlow, yo!
    
    def build_action(named)
      @ok_actions << named.to_sym
    end

  end
end
