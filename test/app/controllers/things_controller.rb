class ThingsController < ApplicationController
  make_resourceful do
    build :all
    belongs_to :person
  end
end
