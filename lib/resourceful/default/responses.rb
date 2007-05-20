module Resourceful
  module Default
    module Responses

     protected
      [:show, :edit, :new, :index].each do |action|
        define_method "response_for_#{action}" do
        end
      end

      def response_for_create
        redirect_to current_object
      end

      def response_for_update
        redirect_to current_objects
      end

      MODIFYING_ACTIONS.each do |action|
        define_method "response_for_#{action}_fails" do
          respond_to do |format|
            format.html do
              redirect_to :back
            end
          end
        end
      end
    end
  end
end
