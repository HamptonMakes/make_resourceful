class UsersController < ApplicationController
  make_resourceful do
    build :index
    
    def magic
      raise "This should not be public."
    end
  end
end
