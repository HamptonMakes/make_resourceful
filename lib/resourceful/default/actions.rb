module Resourceful
  module Default
    module Actions
      def index(controller)
        render :text => current_object.inspect
      end
    end
  end
end
