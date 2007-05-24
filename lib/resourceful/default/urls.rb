module Resourceful
  module Default
    module URLs
      def object_path(object = current_object)
        send("#{current_model_name.underscore}_path", object)
      end

      def objects_path
        send("#{current_model_name.pluralize.underscore}_path")
      end
    end
  end
end
