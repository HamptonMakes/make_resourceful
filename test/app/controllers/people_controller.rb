class PeopleController < ApplicationController
  before_filter :ok_go, :only => [:index, :show, :new, :destroy, :update, :create]
  
  make_resourceful do
    build :index, :show,
          :edit,  :destroy,
          :new,   :update,
          :create
    
#    belongs_to :current_site
    
#    publish :xml, :yaml, :json,
#            :only       =>  :show, # without it makes both available
#            :attributes => [:login,
#                            :created_at,
#                            {:messages => [:title, :body, :created_at]}]
#    publish :xml,
#    :only => :index,
#    :attribute => :login
    
    def hidden
      puts "this should not be public"
    end
    
    before :show do
      @before_show_called = true
    end
    
    response_for :show do # No args!
      redirect_to @person
    end

    # This time, when we use the format() method call, 
    # we are going to use the responds_to block
    response_for :edit do |format|
      format.html { redirect_to @person }
      format.xml { blah }
    end
  end
  
  # This is a custom edit that should override the make_resourceful one
  def edit
    render :text => "I am a custom edit for the person #{current_resource.login}"
  end
end
