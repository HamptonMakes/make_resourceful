module Resourceful
  module Default
    # This file contains various methods to make URL helpers less painful.
    # They provide methods analogous to the standard foo_url and foo_path helpers.
    # However, they use make_resourceful's knowledge of the structure of the controller
    # to allow you to avoid figuring out which method to call and which parent objects it should be passed.
    module URLs
      # This returns the path for the given object,
      # by default current_object[link:classes/Resourceful/Default/Accessors.html#M000012].
      # For example, in HatsController where Hat belongs_to Person,
      # the following are equivalent:
      #
      #   object_path             #=> "/people/42/hats/12"
      #   hat_path(@person, @hat) #=> "/people/42/hats/12"
      # 
      def object_path(object = current_object); object_route(object, 'path'); end
      # Same as object_path, but with the protocol and hostname.
      def object_url (object = current_object); object_route(object, 'url');  end

      # This returns the path for the edit action for the given object,
      # by default current_object[link:classes/Resourceful/Default/Accessors.html#M000012].
      # For example, in HatsController where Hat belongs_to Person,
      # the following are equivalent:
      #
      #   edit_object_path             #=> "/people/42/hats/12/edit"
      #   edit_hat_path(@person, @hat) #=> "/people/42/hats/12/edit"
      # 
      def edit_object_path(object = current_object); edit_object_route(object, 'path'); end
      # Same as edit_object_path, but with the protocol and hostname.
      def edit_object_url (object = current_object); edit_object_route(object, 'url');  end

      # This returns the path for the collection of the current controller.
      # For example, in HatsController where Hat belongs_to Person,
      # the following are equivalent:
      #
      #   objects_path       #=> "/people/42/hats"
      #   hats_path(@person) #=> "/people/42/hats"
      # 
      def objects_path; objects_route('path'); end
      # Same as objects_path, but with the protocol and hostname.
      def objects_url ; objects_route('url');  end

      # This returns the path for the new action for the current controller.
      # For example, in HatsController where Hat belongs_to Person,
      # the following are equivalent:
      #
      #   new_object_path       #=> "/people/42/hats/new"
      #   new_hat_path(@person) #=> "/people/42/hats/new"
      # 
      def new_object_path; new_object_route('path'); end
      # Same as new_object_path, but with the protocol and hostname.
      def new_object_url ; new_object_route('url');  end

      # This prefix is added to the Rails URL helper names
      # before they're called.
      # By default, it's the underscored list of namespaces of the current controller,
      # but it can be overridden if another prefix is needed.
      # Note that if this is overridden,
      # the new method should return a string ending in an underscore.
      #
      # For example, in Admin::Content::PagesController,
      #
      #   url_helper_prefix #=> "admin_content_"
      #
      # Then +object_path+ is the same as <tt>admin_content_page_path(current_object)</tt>.
      def url_helper_prefix
        if defined?(namespace_prefix)
          STDERR.puts <<END.gsub("\n", ' ')
DEPRECATION WARNING: 
The make_resourceful #namespace_prefix accessor
is deprecated and will be removed in 0.3.0.
Override #url_method_prefix instead.
END
          return namespace_prefix
        end
        
        namespaces.empty? ? '' : "#{namespaces.join('_')}_"
      end

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
        send("#{url_helper_prefix}#{name}_#{type}", *(parent_objects + [object]))
      end

      def collection_route(name, type)
        send("#{url_helper_prefix}#{name}_#{type}",  *parent_objects)
      end
    end
  end
end
