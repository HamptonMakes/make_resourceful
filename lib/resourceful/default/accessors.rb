module Resourceful
  # This module contains various methods
  # that are available from actions and callbacks.
  # Default::Accessors and Default::URLs are the most useful to users;
  # the rest are mostly used internally.
  #
  # However, if you want to poke around the internals a little,
  # check out Default::Actions, which has the default Action definitions,
  # and Default::Responses.included, which defines the default response_for[link:classes/Resourceful/Builder.html#M000061] blocks.
  module Default
    # This module contains all sorts of useful methods
    # that allow access to the resources being worked with,
    # metadata about the controller and action,
    # and so forth.
    #
    # Many of these accessors call other accessors
    # and are called by the default make_resourceful actions[link:classes/Resourceful/Default/Actions.html].
    # This means that overriding one method
    # can affect everything else.
    # 
    # This can be dangerous, but it can also be very powerful.
    # make_resourceful is designed to take advantage of overriding,
    # so as long as the new methods accomplish the same purpose as the old ones,
    # everything will just work.
    # Even if you make a small mistake,
    # it's hard to break the controller in any unexpected ways.
    #
    # For example, suppose your controller is called TagsController,
    # but your model is called PhotoTag.
    # All you have to do is override current_model_name:
    #
    #   def current_model_name
    #     "PhotoTag"
    #   end
    #
    # Then current_model will return the PhotoTag model,
    # current_object will call <tt>PhotoTag.find</tt>,
    # and so forth.
    #
    # Overriding current_objects and current_object is particularly useful
    # for providing customized model lookup logic.
    module Accessors
      # Returns an array of all the objects of the model corresponding to the controller.
      # For UsersController, it essentially runs <tt>User.find(:all)</tt>.
      #
      # However, there are a few important differences.
      # First, this method caches is results in the <tt>@current_objects</tt> instance variable.
      # That way, multiple calls won't run multiple queries.
      #
      # Second, this method uses the current_model accessor,
      # which provides a lot of flexibility
      # (see the documentation for current_model for details).
      def current_objects
        @current_objects ||= current_model.find(:all)
      end

      # Calls current_objects and stores
      # the result in an instance variable
      # named after the controller.
      # 
      # For example, in UsersController,
      # calling +load_objects+ sets <tt>@users = current_objects</tt>.
      def load_objects
        instance_variable_set("@#{instance_variable_name}", current_objects)
      end

      # Returns the object referenced by the id parameter
      # (or the newly-created object for the +new+ and +create+ actions).
      # For UsersController, it essentially runs <tt>User.find(params[:id])</tt>.
      #
      # However, there are a few important differences.
      # First, this method caches is results in the <tt>@current_objects</tt> instance variable.
      # That way, multiple calls won't run multiple queries.
      #
      # Second, this method uses the current_model accessor,
      # which provides a lot of flexibility
      # (see the documentation for current_model for details).
      #
      # Note that this is different for a singleton controller,
      # where there's only one resource per parent resource.
      # Then this just returns that resource.
      # For example, if Person has_one Hat,
      # then in HatsController current_object essentially runs <tt>Person.find(params[:person_id]).hat</tt>.
      def current_object
        @current_object ||= if plural?
          current_model.find(params[:id])
        else
          parent_objects[-1].send(instance_variable_name)
        end
      end


      # Calls current_object and stores
      # the result in an instance variable
      # named after the controller.
      # 
      # For example, in UsersController,
      # calling +load_object+ sets <tt>@user = current_object</tt>.
      def load_object
        instance_variable_set("@#{instance_variable_name.singularize}", current_object)
      end

      # Creates a new object of the type of the current model
      # with the current object's parameters.
      # +current_object+ then returns this object for this action
      # instead of looking up a new object.
      #
      # Note that if this is a nested controller,
      # the newly created object will automatically be a child of the current parent object.
      def build_object
        @current_object = if current_model.respond_to? :build
          current_model.build(object_parameters)
        else
          current_model.new(object_parameters)
        end
      end

      # The string name of the current model.
      # By default, this is derived from the name of the controller.
      def current_model_name
        controller_name.singularize.camelize
      end

      # An array of namespaces under which the current controller is.
      # For example, in Admin::Content::PagesController:
      #
      #   namespaces #=> [:admin, :content]
      # 
      def namespaces
        @namespaces ||= self.class.name.split('::').slice(0...-1).map(&:underscore).map(&:to_sym)
      end

      # The name of the instance variable that load_object and load_objects should assign to.
      def instance_variable_name
        controller_name
      end

      # The class of the current model.
      # Note that if this is a nested controller,
      # this instead returns the association object.
      # For examle, in HatsController where Person has_many :hats,
      #
      #   current_model #=> Person.find(params[:person_id]).hats
      #
      # This is useful because the association object uses duck typing
      # to act like a model class.
      # It supplies a find method that's automatically scoped
      # to ensure that the object returned is actually a child of the parent,
      # and so forth.
      def current_model
        if parent_objects.empty? || singular?
          current_model_name.constantize
        else
          parent_objects[-1].send(instance_variable_name)
        end
      end

      # Returns the hash passed as HTTP parameters
      # that defines the new (or updated) attributes
      # of the current object.
      # This is only meaningful for +create+ or +update+.
      def object_parameters
        params[current_model_name.underscore]
      end

      # Returns a list of the names of the parents of the current model.
      # For a non-nested controller, this is <tt>[]</tt>.
      # For example, in HatsController where Group has_many :people and Person has_many :hats,
      #
      #   parents #=> ["group", "person"]
      #
      # Note that nesting must be declared via Builder#belongs_to.
      def parents
        self.class.read_inheritable_attribute :parents
      end

      # Returns the names of the model classes of the parents of the current model.
      # For example, in HatsController where Group has_many :people and Person has_many :hats,
      #
      #   parent_model_names #=> ["Group", "Person"]
      #
      # Note that nesting must be declared via Builder#belongs_to.
      def parent_model_names
        parents.map { |p| p.camelize }
      end

      # Returns the HTTP parameters designating the ids for the parent objects of the current model.
      # For example, in HatsController where Group has_many :people and Person has_many :hats,
      #
      #   parent_params #=> [params[:group_id], params[:person_id]]
      #
      # Note that nesting must be declared via Builder#belongs_to.
      def parent_params
        parents.map { |p| params["#{p}_id"] }
      end

      # Returns the model classes of the parents of the current model.
      # For example, in HatsController where Group has_many :people and Person has_many :hats,
      #
      #   parent_models #=> [Group, Person]
      #
      # Note that nesting must be declared via Builder#belongs_to.
      def parent_models
        parent_model_names.map { |p| p.constantize }
      end

      # Returns the parent objects for the current object.
      # Note that nesting must be declared via Builder#belongs_to.
      #
      # Note also that the results of this method are cached
      # so that multiple calls don't result in multiple SQL queries.
      # In addition, each object except the first is scoped
      # so that it's guaranteed to be a child of its parent object.
      def parent_objects
        return [] if parents.empty?
        return @parent_objects if @parent_objects

        first = parent_models[0].find(parent_params[0])
        @parent_objects = [first]
        parent_params.zip(parents)[1..-1].inject(first) do |object, arr|
          id, name = arr
          @parent_objects << object.send(name.pluralize).find(id)
          @parent_objects[-1]
        end
        @parent_objects
      end

      # Assigns each parent object, as given by parent_objects,
      # to its proper instance variable, as given by parents.
      def load_parent_objects
        parents.zip(parent_objects).map { |name, obj| instance_variable_set("@#{name}", obj) }
      end

      # Returns whether or not the database update in the +create+, +update+, and +destroy+
      # was completed successfully.
      def save_succeeded?
        @save_succeeded
      end

      # Declares that the current databse update was completed successfully.
      # Causes subsequent calls to <tt>save_succeeded?</tt> to return +true+.
      # 
      # This is mostly meant to be used by the default actions,
      # but it can be used by user-defined actions as well.
      def save_succeeded!
        @save_succeeded = true
      end

      # Declares that the current databse update was not completed successfully.
      # Causes subsequent calls to <tt>save_succeeded?</tt> to return +false+.
      # 
      # This is mostly meant to be used by the default actions,
      # but it can be used by user-defined actions as well.
      def save_failed!
        @save_succeeded = false
      end

      # Returns whether or not the current action acts upon multiple objects.
      # By default, the only such action is +index+.
      def plural_action?
        PLURAL_ACTIONS.include?(params[:action].to_sym)
      end

      # Returns whether or not the current action acts upon a single object.
      # By default, this is the case for all actions but +index+.
      def singular_action?
        !plural_action?
      end

      # Returns whether the controller is a singleton,
      # implying that there is only one such resource for each parent resource.
      #
      # Note that the way this is determined is based on the singularity of the controller name,
      # so it may yield false positives for oddly-named controllers and need to be overridden.
      def singular?
        instance_variable_name.singularize == instance_variable_name
      end

      # Returns whether the controller is a normal plural controller,
      # implying that there are multiple resources for each parent resource.
      #
      # Note that the way this is determined is based on the singularity of the controller name,
      # so it may yield false negatives for oddly-named controllers.
      # If this is the case, the singular? method should be overridden.
      def plural?
        !singular?
      end
    end
  end
end
