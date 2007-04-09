
require 'test/mocks/user'

# Very simple User controller

module SimpleControllers
  class UsersController < ActionController::Base
    make_resourceful do
      build :index

      def magic
        puts "MAGICK is called"
      end
    end
  
   protected
    
    def controller
      return self
    end
  
    def controller_name
      "users"
    end
  
    def params
      {:id => "82"}
    end
  end
end
