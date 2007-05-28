class ThingsController < ApplicationController
  make_resourceful do
    build :all
    belongs_to :person
    associated_with :current_user
  end
end
