
require 'rubygems'
require 'action_controller'
require 'resourceful/maker'
require 'test/unit'
ActionController::Base.extend Resourceful::Maker
require 'test/mocks/simple_users_controller'
require 'test/mocks/empty_users_controller'
