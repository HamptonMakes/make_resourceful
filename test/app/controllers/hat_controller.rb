class HatController < ApplicationController
  make_resourceful do
    actions :all

    belongs_to :user
  end
end
