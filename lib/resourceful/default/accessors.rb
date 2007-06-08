module Resourceful
  module Default
    module Accessors
      # current_objects returns an array representing the
      # best-guess for what an index-like action might want
      #
      # It basically preforms:
      #
      #   User.find(:all, :include => auto_include)
      #
      # However, it is built off of current_model... which
      # provides a lot of flexibility. If you override this method
      # try and use current_model to build off of.
      #
      # For instance, if you wanted to limit to 5 entries.
      #
      #   def current_objects
      #     @current_objects ||=current_model.find(:all, :limit => 5)
      #   end
      #
      # Notice its recommended to cache the results
      # so that multiple calls to this method do not
      # require executing SQL calls.
      #
      def current_objects
        @current_objects ||= current_model.find(:all, :include => model_includes)
      end

      # This method will call current_objects and store
      # the results in an instance variable based
      # off the name of the controller.
      #
      # For instance, after this is called in a UsersController:
      #
      #   @users #=> current_objects
      #
      def load_objects
        instance_variable_set("@#{instance_variable_name}", current_objects)
      end

      # current_object returns an object representing the
      # best-guess for what a show-like action might need for
      # resource data.
      #
      # It basically preforms:
      #
      #   User.find(params[:id], :include => auto_include)
      #
      # However, it is built off of current_model... which
      # provides a lot of flexibility. If you override this method
      # try and use current_model to build off of.
      #
      # For instance, if you wanted to limit to 5 entries.
      #
      #   def current_objects
      #     @current_objects ||=current_model.find(current_params, :limit => 5)
      #   end
      #
      # Notice its recommended to cache the results
      # so that multiple calls to this method do not
      # require executing SQL calls.
      #
      def current_object
        @current_object ||= current_model.find(current_param)
      end

      
      # This method will call current_object and store
      # the results in an instance variable based
      # off the singularized name of the controller.
      #
      # For instance, after this is called in a UsersController:
      #
      #   @user #=> current_object
      #
      def load_object
        instance_variable_set("@#{instance_variable_name.singularize}", current_object)
      end

      def build_object
        @current_object = if current_model.respond_to? :build
          current_model.build(object_parameters)
        else
          current_model.new(object_parameters)
        end
      end

      def current_model_name
        controller_name.singularize.camelize
      end

      def namespaces
        @namespaces ||= self.class.name.split('::').slice(0..-2).map(&:underscore).map(&:to_sym)
      end

      def instance_variable_name
        controller_name.underscore.gsub /_controller$/, ""
      end

      def current_model
        if parent_objects.empty?
          current_model_name.constantize
        else
          parent_objects[-1].send(instance_variable_name)
        end
      end

      def current_param
        params[:id]
      end

      def object_parameters
        params[instance_variable_name.singularize.to_sym]
      end

      def model_includes
        Hash.new
      end

      def response_for(action)
        send("response_for_#{action}")
      end

      def parents
        self.class.read_inheritable_attribute :parents
      end

      def parent_model_names
        parents.map { |p| p.camelize }
      end

      def parent_models
        parent_model_names.map { |p| p.constantize }
      end

      def parent_params
        parents.map { |p| params["#{p}_id"].to_i }
      end

      # Returns an array of all of the parent objects
      # as defined in belongs_to :thing
      def parent_objects
        return [] if parents.empty?
        return @parent_objects if @parent_objects

        first = parent_models[0].find(parent_params[0])
        @parent_objects = [first]
        parent_params.zip(parents)[1..-1].inject(first) do |memo, arr|
          id, name = arr
          @parent_objects << memo.send(name.pluralize).find(id)
        end
        @parent_objects
      end

      def load_parent_objects
        parents.zip(parent_objects).map { |name, obj| instance_variable_set("@#{name}", obj) }
      end

      def save_succeeded?
        @save_succeeded
      end

      def save_succeeded!
        @save_succeeded = true
      end

      def save_failed!
        @save_succeeded = false
      end
    end
  end
end
