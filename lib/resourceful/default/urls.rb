module Resourceful
  module Default
    module URLs
      def object_path(object = current_object)
        instance_path(current_model_name.underscore, object)
      end

      def objects_path
        collection_path(current_model_name.pluralize.underscore)
      end

      def new_object_path
        collection_path("new_#{current_model_name.underscore}")
      end

      def edit_object_path(object = current_object)
        instance_path("edit_#{current_model_name.underscore}", object)
      end

     private
      def instance_path(name, object)
        send("#{namespace_prefix}#{name}_path", *(parent_objects + [object]))
      end

      def collection_path(name)
        send("#{namespace_prefix}#{name}_path", *parent_objects)
      end

      def namespace_prefix
        namespaces.empty? ? '' : "#{namespaces.join('_')}_"
      end
    end
  end
end
