require 'test/mocks/user'

# Very complex User controller

module ComplexControllers
  class UsersController < ActionController::Base
    before_filter :ok_go, :only => [:index, :show, :new, :destroy, :update, :create]

    make_resourceful do
      build :index, :show,
            :edit,  :destroy,
            :new,   :update,
            :create

      belongs_to :current_site

      publish :types      => [:xml, :yaml, :json],
              :only       =>  :show, # without it makes both available
              :attributes => [:login,
                              :created_at,
                              {:messages => [:title, :body, :created_at]}]
      publish :type => :xml,
              :only => :index,
              :attribute => :login

      def hidden
        puts "this should not be public"
      end

      before :show do
        @before_show_called = true
      end
    end

    # This is a custom edit that should override the make_resourceful one
    def edit
      render :text => "i am custom for edit for the user #{current_resource.login}"
    end


   # methods to mock a real controller
   protected
   
    def ok_go
      @filters_called = true
    end
    
    def controller
      return self
    end
  
    def controller_name
      "users"
    end
  
    def params
      {:id => "82"}
    end
  end
end
