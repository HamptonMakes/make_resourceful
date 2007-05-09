
require 'resourceful/default/actions'

module Resourceful
  ACTIONS = [:index, :show, :edit, :update, :create, :new, :destroy]

  module Builder

    def self.construct(controller_klass, &block)
      # Add in all those super-helpful little babies
      # TODO: Make private
      puts controller_klass.to_s
      controller_klass.extend Resourceful::Default::Accessors

      # Now, for some meta shit!
      #   --- Too bad _why already took HacketyHack as a name!
      Constructor.new(controller_klass, &block)
    end

    
    # Constructor is my ninja-trick to make
    # all of this crazy syntax work right.
    #
    # The only way to get blocks to eval the way I'd
    # like them to is to use Modules. But, vanilla
    # modules don't have the class methods I need.
    #
    # Therefore, EXTEND Module. How much more
    # meta can you fucking get. Seriously.
    #
    # Alright, let me drink more rum before I code
    
    class Constructor < Module

     
      def initialize(controller_klass, &block)
        @controller_klass = controller_klass
        @action_module    = Resourceful::Default::Actions.dup
        @ok_actions       = []

        super(&block)

        Resourceful::ACTIONS.each do |action_named|
          unless @ok_actions.include? action_named
            @action_module.send :remove_method, action_named
          end
        end

        @controller_klass.extend(@action_module)
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
end
