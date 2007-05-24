module Resourceful
  module Default
    module URLs
      def object_path(object = current_object)
        send("#{current_model_name.underscore}_path", *(parent_objects + [object]))
      end

      def objects_path
        send("#{current_model_name.pluralize.underscore}_path", *parent_objects)
      end
    end
  end
end
