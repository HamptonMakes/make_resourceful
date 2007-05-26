require 'resourceful/builder'

module Resourceful
  module Default
    module Callbacks
      def before(action)
        resourceful_fire(:before, action.to_sym)
      end

      def after(action)
        resourceful_fire(:after, action.to_sym)
      end

      def response_for(action)
        if responses = self.class.read_inheritable_attribute(:resourceful_responses)[action.to_sym]
          respond_to do |format|
            responses.each do |key, value|
              format.send(key, &scope(value))
            end
          end
        else
          send "response_for_#{action}"
        end
      end

      def resourceful_fire(type, name)
        scope(self.class.read_inheritable_attribute(:resourceful_callbacks)[type][name]).call
      end

      def scope(block)
        lambda do
          instance_eval(&(block || lambda {}))
        end
      end
    end
  end
end
