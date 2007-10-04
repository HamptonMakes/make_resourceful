module Resourceful
  module Default
    module URLs
      def object_path(object = current_object); object_route(object, 'path'); end
      def object_url (object = current_object); object_route(object, 'url');  end

      def edit_object_path(object = current_object); edit_object_route(object, 'path'); end
      def edit_object_url (object = current_object); edit_object_route(object, 'url');  end

      def objects_path; objects_route('path'); end
      def objects_url ; objects_route('url');  end

      def new_object_path; new_object_route('path'); end
      def new_object_url ; new_object_route('url');  end

     private
      def object_route(object, type)
        instance_route(current_model_name.underscore, object, type)
      end

      def edit_object_route(object, type)
        instance_route("edit_#{current_model_name.underscore}", object, type)
      end

      def objects_route(type)
        collection_route(current_model_name.pluralize.underscore, type)
      end

      def new_object_route(type)
        collection_route("new_#{current_model_name.underscore}", type)
      end

      def instance_route(name, object, type)
        send("#{namespace_prefix}#{name}_#{type}", *(parent_objects + [object]))
      end

      def collection_route(name, type)
        send("#{namespace_prefix}#{name}_#{type}",  *parent_objects)
      end

      def namespace_prefix
        namespaces.empty? ? '' : "#{namespaces.join('_')}_"
      end
    end
  end
end
