require 'resourceful/builder'

module Resourceful
  module Default
    module Callbacks
      def before(action)
        resourceful_fire("before_#{action}".intern)
      end
      
      def after(action)
        resourceful_fire("after_#{action}".intern)
      end
      
      def response_for(action)
        responses = self.class.read_inheritable_attribute(:resourceful_responses)[action.to_sym]
        responses ||= {:html => Resourceful::Builder::DEFAULT_FORMAT_RENDERS[:html]}
        respond_to do |format|
          responses.each do |key, value|
            format.send(key, &scope(value))
          end
        end
      end
      
      def resourceful_fire(callback_name)
        scope(self.class.read_inheritable_attribute(:resourceful_callbacks)[callback_name]).call
      end

      def scope(block)
        lambda do
          instance_eval(&(block || lambda {}))
        end
      end
    end
  end
end
