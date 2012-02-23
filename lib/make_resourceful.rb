
class MakeResourcefulTie < Rails::Railtie
  initializer "my_railtie.configure_rails_initialization" do
    require_relative 'resourceful/maker'
    ActionController::Base.extend Resourceful::Maker
  end
end