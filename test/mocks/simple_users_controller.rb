
require 'test/mocks/user'

# Very simple User controller

module SimpleControllers
  class UsersController < ActionController::Base
    make_resourceful do
      build :index

      def magic
        puts "this should not be public"
      end
    end


   # methods to mock a real controller
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
