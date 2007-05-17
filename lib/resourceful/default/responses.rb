module Resourceful
  module Default
    module Responses

     protected
      ACTIONS.each do |action|
        define_method "response_for_#{action}" do
          respond_to do |format|
            format.html
          end
        end
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
