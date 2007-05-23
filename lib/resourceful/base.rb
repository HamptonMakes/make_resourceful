module Resourceful
  # We want to define some stuff before we load other modules

  ACTIONS = [:index, :show, :edit, :update, :create, :new, :destroy]
  MODIFYING_ACTIONS = [:update, :create, :destroy]
end

require 'resourceful/default/accessors'
require 'resourceful/default/responses'
require 'resourceful/default/callbacks'

module Resourceful::Base
  include Resourceful::Default::Accessors
  include Resourceful::Default::Responses
  include Resourceful::Default::Callbacks
end
