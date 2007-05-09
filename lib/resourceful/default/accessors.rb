module Resourceful
  module Default
    module Accessors
     protected
      def current_objects
        @current_objects ||= current_model.find(:all, :include => model_includes)
      end

      def current_object
        @current_object  ||= current_model.find(current_param)
      end

      def current_model_name
        controller.controller_name.singularize.titleize
      end

      def current_model
        current_model_name.constantize
      end

      def current_param
        params[:id]
      end

      def model_includes
        Hash.new
      end
    end
  end
end
