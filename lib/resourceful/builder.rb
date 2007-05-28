require 'resourceful/response'
require 'resourceful/default/actions'

module Resourceful
  class Builder
    @@formats = {}

    def self.register_format(name, &block)
      @@formats[name] = block
    end

    def initialize
      @action_module    = Resourceful::Default::Actions.dup
      @ok_actions       = []
      @callbacks        = {:before => {}, :after => {}}
      @responses        = {}
      @parents          = []
      @associations     = {}
    end

    def apply(kontroller) # :nodoc:
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
      kontroller.read_inheritable_attribute(:resourceful_associations).merge! @associations

      kontroller.write_inheritable_attribute(:parents, @parents)
      kontroller.before_filter { |c| c.send(:load_parent_objects) }
    end
      
    def actions(*available_actions)
      available_actions = ACTIONS if available_actions.first == :all
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

    # Use this method to assign associations that
    # are method-accessable and not in the belongs_to
    # (aka, url scoped) declaration.
    #
    # This would be commonly used to assign the current_user
    # as the owner, when #current_user is defined.
    #
    # The assignment-method that happens on the object
    # is guessed to be the underscored class-name of the
    # returned object.
    #
    # If you are using STI or other things... where the
    # AR object wants to be assigned with a name
    # that might be different than the class returned, then
    # use :assign_with => name
    #
    # Example usages:
    # 
    #   # Assigns current_object.user=
    #   # because #current_user returns a User
    #   associate_with :current_user
    #   
    #   # Assigns current_object.admin=
    #   # #current_juror can return anything
    #   associate_with :current_juror,
    #                      :assign_with => :admin
    #
    def associated_with(element, options={})
      @associations[element] = options[:assign_with] || nil
    end

    def publish(*types)
      options = (Hash === types[-1] ? types[-1] : {})
      if options[:attribute]
        options[:attributes] = Array(options.delete(:attribute))
      end
      actions = (options.delete(:only) || [:show, :index]) - (options.delete(:except) || [])

      actions.each do |action|
        response_for action do |format|
          types.each do |type|
            format.send(type, &@@formats[type].to_proc(options))
          end
        end
      end
    end

    def belongs_to(*parents)
      @parents = parents.map { |p| p.to_s }
    end
  end
end
