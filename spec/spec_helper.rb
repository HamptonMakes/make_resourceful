%w(rubygems spec action_pack active_record).each(&method(:require))
$: << File.dirname(__FILE__) + '/../lib'
require 'resourceful/maker'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

def should_be_called(&block)
  pstub = stub
  pstub.expects(:call).instance_eval(&(block || proc {}))
  proc { |*args| pstub.call(*args) }
end

def stub_model(name)
  model = Class.new do
    include Resourceful::Serialize::Model

    def self.to_s
      @name
    end

    def initialize(attrs = {})
      attrs.each do |k, v|
        self.stubs(k).returns(v)
      end
    end

    def inspect
      "#<#{self.class.send(:instance_variable_get, '@name')}>"
    end
  end
  model.send(:instance_variable_set, '@name', name)
  model
end

module Spec::Matchers
  def have_any(&proc)
    satisfy { |a| a.any?(&proc) }
  end
end

module ControllerMocks
  def mock_kontroller(to_extend = Module.new)
    @kontroller = Class.new
    @kontroller.extend Resourceful::Maker
    @kontroller.extend to_extend

    @hidden_actions = Resourceful::ACTIONS.dup
    @kontroller.stubs(:hidden_actions).returns(@hidden_actions)
    @kontroller.stubs(:plural_action?).returns(false)
    @kontroller.stubs(:include)
    @kontroller.stubs(:before_filter)
    @kontroller.stubs(:helper_method)
  end

  def mock_controller(to_extend = Module.new)
    mock_kontroller
    @controller = @kontroller.new
    @controller.extend to_extend
  end

  def mock_builder
    @builder = stub
    @builder.stubs(:response_for)
    @builder.stubs(:apply)
    @builder.stubs(:instance_eval).yields(@buildercc )
    Resourceful::Base.stubs(:made_resourceful).returns([])
    Resourceful::Builder.stubs(:new).returns(@builder)
  end

  def responses
    @kontroller.read_inheritable_attribute(:resourceful_responses)
  end

  def stub_responses(value)
    @kontroller.write_inheritable_attribute(:resourceful_responses, value)
  end

  def callbacks
    @kontroller.read_inheritable_attribute(:resourceful_callbacks)
  end

  def stub_callbacks(value)
    @kontroller.write_inheritable_attribute(:resourceful_callbacks, value)
  end

  def parents
    @kontroller.read_inheritable_attribute(:parents)
  end

  def stub_parents(value)
    @kontroller.write_inheritable_attribute(:parents, value)
  end
end
