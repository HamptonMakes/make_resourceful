require File.dirname(__FILE__) + '/spec_helper'

describe Resourceful::Builder, " applied without any modification" do
  include ControllerMocks
  before :each do
    mock_controller
    @builder = Resourceful::Builder.new(@controller)
  end

  it "should remove all resourceful actions" do
    @controller.expects(:send).with do |name, action_module|
      name == :include && (action_module.instance_methods & Resourceful::ACTIONS).empty?
    end
    @builder.apply
  end

  it "shouldn't un-hide any actions" do
    @builder.apply
    @controller.hidden_actions.should == Resourceful::ACTIONS
  end

  it "shouldn't set any callbacks" do
    @builder.apply
    @controller.read_inheritable_attribute(:resourceful_callbacks).should == {:before => {}, :after => {}}
  end

  it "shouldn't set any responses" do
    @builder.apply
    @controller.read_inheritable_attribute(:resourceful_responses).should be_empty
  end

  it "shouldn't set any parents" do
    @builder.apply
    @controller.read_inheritable_attribute(:parents).should be_empty
  end

  it "should set load_parent_objects as a before_filter" do
    yielded = stub
    @controller.expects(:before_filter).yields(yielded)
    yielded.expects(:send).with(:load_parent_objects)
    @builder.apply
  end
end
