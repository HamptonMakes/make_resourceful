
require 'resourceful/default/actions'

module Resourceful
  module Builder
    def self.construct(controller_klass, &block)
      contruct = Constructor.new(controller_klass, &block)
    end

    class Constructor < Module

      def initialize(controller_klass, &block)
        @controller_klass = controller_klass
        super(&block)
      end
      
      def build_action(named)
        create_method(named) { Resourceful::Default::Actions.index }
      end
      
      def build(*available_actions)
        available_actions.each { |available_action| build_action(available_action)}
      end

      def create_method(name, &block)
        @controller_klass.send(:define_method, name, &block)
      end
    end

  end
end
