module Resourceful
  module Default
    module Responses

     protected

      # set_default_flash is a nice little helper for responses
      # that lets you set a "default" flash message
      # to respond to a problem. The default
      # responses have default flash messages.
      # You can override these by doing a manual response
      # or by passing in parameter that specifies the flash
      # message.
      #
      # There is no reason why a user shouldn't be able to
      # be trusted for their message! Flash messages are
      # only shown for :notice and :error... and only when
      # one of them actually happens.
      #
      # With this technique, you can easily have multiple
      # forms post to the same create/edit/destroy
      # actions and have different flash notices.... determined
      # by the actor itself.
      #
      # This accepts the params "_flash[notice]" and "_flash[error]"
      # when in use. Others can be used if desired.
      #
      # TODO: Move this out of here
      def set_default_flash(type, message)
        flash[type] = (params[:_flash] && params[:_flash][type]) || message
      end

      # Similar to set_flash, this will allow a posted
      # parameter to determine where the user is going
      # to be redirected after an action has occured
      #
      # This is useful, because this shouldn't be a
      # dangerous activity at all... and helps us
      # build re-usable CUD actions that might
      # be 'hit' from multiple HTML locations.
      #
      # Post: redirect_on[success] and redirect_on[fail]
      #
      # TODO: Move this out of here
      def set_default_redirect(default, options = {})
        on = options[:on] || :success
        redirect_to (params[:_redirect_on] && params[:_redirect_on][on]) || default
      end

      [:show, :edit, :new, :index].each do |action|
        define_method("response_for_#{action}") {}
      end

      def response_for_create
        set_default_flash(:notice, "Create successful!")
        set_default_redirect object_path
      end

      def response_for_create_fails
        set_default_flash :error, "There was a problem!"
        render({:action => :new},
               :status => :unprocessable_entity)
      end

      def response_for_update
        set_default_flash :notice, "Save successful!"
        set_default_redirect objects_path
      end

      def response_for_update_fails
        set_default_flash :error, "There was a problem saving!"
        render :action => :edit
      end

      def response_for_destroy
        set_default_flash :notice, "Record deleted!"
        set_default_redirect objects_path
      end

      def response_for_destroy_fails
        set_default_flash :error, "There was a problem deleting."
        set_default_redirect(:back,
                             :on     => :fail)
      end
      
    end
  end
end
