module Resourceful
  module Default
    module Accessors
     protected
      def current_objects
        @current_objects ||= current_model.find(:all, :include => model_includes)
      end

      def load_objects
        eval "@#{instance_variable_name} = current_objects"
      end

      def current_object
        @current_object  ||= current_model.find(current_param)
      end

      def load_object
        eval "@#{instance_variable_name.singularize} = current_object"
      end

      def build_object
        if current_model.respond_to? :build
          current_model.build(object_parameters)
        else
          current_model.new(object_parameters)
        end
      end

      def current_model_name
        controller_name.singularize.titleize
      end

      def instance_variable_name
        controller_name.underscore.gsub /_controller$/, ""
      end

      def current_model
        current_model_name.constantize
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
    end
  end
end
