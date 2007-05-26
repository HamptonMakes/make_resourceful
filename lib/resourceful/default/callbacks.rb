require 'resourceful/builder'

module Resourceful
  module Default
    module Callbacks
      def before(action)
        resourceful_fire(:before, action)
      end

      def after(action)
        resourceful_fire(:after, action)
      end

      def response_for(action)
        respond_to do |format|
          self.class.read_inheritable_attribute(:resourceful_responses)[action.to_sym].each do |key, value|
            format.send(key, &scope(value))
          end
        end
      rescue
        send "response_for_#{action}"
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
