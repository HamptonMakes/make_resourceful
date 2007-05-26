class PropertiesController < ApplicationController
  make_resourceful do
    build :all
    belongs_to :person, :thing
  end
end
