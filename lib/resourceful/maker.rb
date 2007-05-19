require 'resourceful/builder'
require 'resourceful/base'

module Resourceful
  module Maker
    def make_resourceful(*args, &block)
      include Resourceful::Base

      builder = Resourceful::Builder.new
      builder.instance_eval(&block)
      builder.apply(self)
    end
  end
end
