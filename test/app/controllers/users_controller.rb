class UsersController < ApplicationController
  make_resourceful do
    build :index, :show, :destroy
    
    def magic
      raise "This should not be public."
    end
  end
end
