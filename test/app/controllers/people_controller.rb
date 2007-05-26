class PeopleController < ApplicationController
  before_filter :ok_go, :only => [:index, :show, :new, :destroy, :update, :create]
  
  make_resourceful do
    build :index, :show,
          :edit,  :destroy,
          :new,   :update,
          :create

    def hidden
      puts "this should not be public"
    end
    
    before :show do
      @before_show_called = true
    end
    
    response_for :show do
      redirect_to person_path(@person)
    end

    before :edit, :new do
      @before_edit_and_new = true
    end

    response_for :index, :destroy do |format|
      format.html { render :text => "HTML" }
      format.json { render :json => "JSON".to_json }
    end
  end
  
  # This is a custom edit that should override the make_resourceful one
  def edit
    render :text => "<p>I am a custom edit for the person #{current_object.name}</p>"
  end
end
