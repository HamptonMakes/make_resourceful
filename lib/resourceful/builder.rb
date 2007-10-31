require 'resourceful/response'
require 'resourceful/serialize'
require 'resourceful/default/actions'

module Resourceful
  # The Maker#make_resourceful block is evaluated in the context
  # of an instance of this class.
  # It provides various methods for customizing the behavior of the actions
  # built by make_resourceful.
  #
  # All instance methods of this class are available in the +make_resourceful+ block.
  class Builder
    # The klass of the controller on which the builder is working.
    attr :controller, true

    # The constructor is only meant to be called internally.
    #
    # This takes the klass (class object) of a controller
    # and constructs a Builder ready to apply the make_resourceful
    # additions to the controller.
    def initialize(kontroller)
      @controller       = kontroller
      @action_module    = Resourceful::Default::Actions.dup
      @ok_actions       = []
      @callbacks        = {:before => {}, :after => {}}
      @responses        = {}
      @publish          = {}
      @parents          = []
    end

    # This method is only meant to be called internally.
    #
    # Applies all the changes that have been declared
    # via the instance methods of this Builder
    # to the kontroller passed in to the constructor.
    def apply
      apply_publish

      kontroller = @controller
      Resourceful::ACTIONS.each do |action_named|
        # See if this is a method listed by #actions
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
      options = {
        :only => [:show, :index]
      }.merge(Hash === types.last ? types.pop : {})
      raise "Must specify :attributes option" unless options[:attributes]
      
      Array(options.delete(:only)).each do |action|
        @publish[action] ||= []
        types.each do |type|
          type = type.to_sym
          @publish[action] << [type, proc do
            render_action = [:json, :xml].include?(type) ? type : :text
            render render_action => (plural_action? ? current_objects : current_object).serialize(type, options)
          end]
        end
      end
    end

    def belongs_to(*parents)
      @parents = parents.map(&:to_s)
    end

    private
    
    def apply_publish
      @publish.each do |action, types|
        @responses[action.to_sym] ||= []
        @responses[action.to_sym] += types
      end
    end
  end
end
