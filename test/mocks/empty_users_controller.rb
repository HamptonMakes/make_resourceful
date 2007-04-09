
require 'test/mocks/user'

# Very simple User controller

module EmptyControllers
  class UsersController < ActionController::Base
    make_resourceful do
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
