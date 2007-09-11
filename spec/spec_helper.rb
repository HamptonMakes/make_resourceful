%w(rubygems spec action_pack active_record).each(&method(:require))
$: << File.dirname(__FILE__) + '/../lib'
require 'resourceful/maker'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

module ControllerMocks
  def mock_controller
    @controller = Class.new
    @controller.extend Resourceful::Maker

    @hidden_actions = Resourceful::ACTIONS.dup
    @controller.stubs(:hidden_actions).returns(@hidden_actions)
    @controller.stubs(:include)
    @controller.stubs(:before_filter)
    @controller.stubs(:helper_method)
  end

  def mock_builder
    @builder = stub
    @builder.stubs(:response_for)
    @builder.stubs(:apply)
    @builder.stubs(:instance_eval).yields(@buildercc )
    Resourceful::Base.stubs(:made_resourceful).returns([])
    Resourceful::Builder.stubs(:new).returns(@builder)
  end

  def should_be_called(&block)
    pstub = stub
    pstub.expects(:call).instance_eval(&(block || proc {}))
    proc { |*args| pstub.call(*args) }
  end
end
