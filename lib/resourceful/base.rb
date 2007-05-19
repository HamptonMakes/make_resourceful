require 'resourceful/default/accessors'

module Resourceful
  ACTIONS = [:index, :show, :edit, :update, :create, :new, :destroy]
  MODIFYING_ACTIONS = [:update, :create, :destroy]

  module Base
    include Resourceful::Default::Accessors
    include Resourceful::Default::Responses
    include Resourceful::Default::Callbacks
  end
end
