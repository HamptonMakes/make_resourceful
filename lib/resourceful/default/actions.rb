module Resourceful
  module Default
    module Actions
      def self.index(controller)
        controller.render :text => "Boomba!"
      end
    end
  end
end
