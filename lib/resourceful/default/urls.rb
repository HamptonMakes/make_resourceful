module Resourceful
  module Default
    module URLs
      def object_path(object = current_object)
        send("#{namespace_prefix}#{current_model_name.underscore}_path", *(parent_objects + [object]))
      end

      def objects_path
        send("#{namespace_prefix}#{current_model_name.pluralize.underscore}_path", *parent_objects)
      end

     private
      def namespace_prefix
        namespaces.empty? ? '' : "#{namespaces.join('_')}_"
      end
    end
  end
end
