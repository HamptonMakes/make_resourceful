
class MakeResourcefulTie < Rails::Railtie
  initializer "my_railtie.configure_rails_initialization" do
    require File.join(File.dirname(__FILE__), 'resourceful/maker')
    ActionController::Base.extend Resourceful::Maker
  end
end