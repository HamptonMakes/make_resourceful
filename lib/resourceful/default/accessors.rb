module Resourceful
  module Default
    module Accessors
      def current_objects
        @current_objects ||= current_model.find(:all, :include => model_includes)
      end

      def current_object
        @current_object  ||= current_model.find(current_param)
      end

      def current_model
        controller.controller_name.singularize.titleize.constantize
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
