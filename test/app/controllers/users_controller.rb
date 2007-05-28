class UsersController < ApplicationController
  make_resourceful do
    actions :index, :show, :destroy
    
    def magic
      raise "This should not be public."
    end
  end
end
