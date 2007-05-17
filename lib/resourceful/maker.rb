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

    def before(action)
      resourceful_fire("before_#{action}".intern)
    end

    def after(action)
      resourceful_fire("after_#{action}".intern)
    end

    def resourceful_fire(callback_name)
      read_inheritable_attribute(:resourceful_callbacks)[callback_name].call
    end
  end
end
