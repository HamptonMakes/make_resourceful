class ThingsController < ApplicationController
  make_resourceful do
    build :all
    belongs_to :person
    associated_with :current_user
  end

  def preview
    render :text => build_object.name, :layout => false
  end
end
