
require 'resourceful/default/actions'

module Resourceful
  ACTIONS = [:index, :show, :edit, :update, :create, :new, :destroy]

  class Builder

    def initialize(controller_klass, &block)
      # Add in all those super-helpful little babies
      # TODO: Make private
      puts controller_klass.to_s
      controller_klass.send :include, Resourceful::Default::Accessors

      @controller_klass = controller_klass
      @action_module    = Resourceful::Default::Actions.dup
      @ok_actions       = []
      
      self.instance_eval &block
      
      Resourceful::ACTIONS.each do |action_named|
        unless @ok_actions.include? action_named
          @action_module.send :remove_method, action_named
        end
      end
      
      @controller_klass.hidden_actions.reject! &@ok_actions.method(:include?)
      @controller_klass.send :include, @action_module
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
