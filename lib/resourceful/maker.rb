require 'resourceful/builder'
require 'resourceful/base'

module Resourceful
  module Maker
    def make_resourceful(*args, &block)
      include Resourceful::Base

      Resourceful::Builder.new(self, &block)
    end
  end
end
