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

    def response_for(action)
      respond_to do |format|
        read_inheritable_attribute(:resourceful_responses)[action.to_sym].each do |key, value|
          format.send(key, scope(value))
        end
      end
    end

    def resourceful_fire(callback_name)
      scope(read_inheritable_attribute(:resourceful_callbacks)[callback_name]).call
    end

    private

    def scope(&block)
      Proc.new { |*args, &block| instance_eval(&proc) }
    end
  end
end
