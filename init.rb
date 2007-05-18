require 'resourceful/maker'

ActionController::Base.extend(Resourceful::Maker)
ActionController::Base.write_inheritable_attribute :resourceful_callbacks, {}
ActionController::Base.write_inheritable_attribute :resourceful_responses, {}
