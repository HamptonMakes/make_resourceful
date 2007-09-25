require File.dirname(__FILE__) + '/spec_helper'

describe Resourceful::Builder, " applied without any modification" do
  include ControllerMocks
  before :each do
    mock_controller
    @builder = Resourceful::Builder.new(@controller)
  end

  it "should remove all resourceful actions" do
    @controller.expects(:send).with do |name, action_module|
      name == :include && (action_module.instance_methods & Resourceful::ACTIONS.map(&:to_s)).empty?
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

describe Resourceful::Builder, " with some actions set" do
  include ControllerMocks
  before :each do
    mock_controller
    @builder = Resourceful::Builder.new(@controller)
    @actions = [:show, :index, :new, :create]
    @builder.actions *@actions
  end

  it "should include the given actions" do
    @controller.expects(:send).with do |name, action_module|
      name == :include && (action_module.instance_methods & Resourceful::ACTIONS.map(&:to_s)).sort ==
        @actions.map(&:to_s).sort
    end
    @builder.apply
  end

  it "should un-hide the given actions" do
    @builder.apply
    (@controller.hidden_actions & @actions).should be_empty
  end
end

describe Resourceful::Builder, " with all actions set for a plural controller" do
  include ControllerMocks
  before :each do
    mock_controller
    @controller.class_eval { def plural?; true; end }
    @builder = Resourceful::Builder.new(@controller)
    @builder.actions :all
  end

  it "should include all actions" do
    @controller.expects(:send).with do |name, action_module|
      name == :include && (action_module.instance_methods & Resourceful::ACTIONS.map(&:to_s)).sort ==
        Resourceful::ACTIONS.map(&:to_s).sort
    end
    @builder.apply
  end
end

describe Resourceful::Builder, " with all actions set for a singular controller" do
  include ControllerMocks
  before :each do
    mock_controller
    @controller.class_eval { def plural?; false; end }
    @builder = Resourceful::Builder.new(@controller)
    @builder.actions :all
  end

  it "should include all singular actions" do
    @controller.expects(:send).with do |name, action_module|
      name == :include && (action_module.instance_methods & Resourceful::ACTIONS.map(&:to_s)).sort ==
        Resourceful::SINGULAR_ACTIONS.map(&:to_s).sort
    end
    @builder.apply
  end
end

describe Resourceful::Builder, " with several before and after callbacks set" do
  include ControllerMocks
  before :each do
    mock_controller
    @builder = Resourceful::Builder.new(@controller)
    @builder.before(:create, :update, 'destroy', &(should_be_called { times(3) }))
    @builder.after('index', &should_be_called)
    @builder.after(:update, &should_be_called)
    @builder.apply
  end

  it "should save the callbacks as the :resourceful_callbacks inheritable_attribute" do
    callbacks = @controller.read_inheritable_attribute(:resourceful_callbacks)
    callbacks[:before][:create].call
    callbacks[:before][:update].call
    callbacks[:before][:destroy].call
    callbacks[:after][:index].call
    callbacks[:after][:update].call
  end
end

describe Resourceful::Builder, " with responses set for several formats" do
  include ControllerMocks
  before :each do
    mock_controller
    @builder = Resourceful::Builder.new(@controller)
    @builder.response_for('create') do |f|
      f.html(&should_be_called)
      f.js(&should_be_called)
      f.yaml(&should_be_called)
      f.xml(&should_be_called)
      f.txt(&should_be_called)
    end
    @builder.response_for(:remove_failed, 'update') do |f|
      f.yaml(&(should_be_called { times(2) }))
      f.png(&(should_be_called { times(2) }))
    end
    @builder.apply
  end

  it "should save the responses as the :resourceful_responses inheritable_attribute" do
    responses = @controller.read_inheritable_attribute(:resourceful_responses)
    responses[:create].map(&:first).should == [:html, :js, :yaml, :xml, :txt]
    responses[:create].map(&:last).each(&:call)

    responses[:remove_failed].map(&:first).should == [:yaml, :png]
    responses[:remove_failed].map(&:last).each(&:call)

    responses[:update].map(&:first).should == [:yaml, :png]
    responses[:update].map(&:last).each(&:call)
  end
end

describe Resourceful::Builder, " with a response set for the default format" do
  include ControllerMocks
  before :each do
    mock_controller
    @builder = Resourceful::Builder.new(@controller)
    @builder.response_for('index', &should_be_called)
    @builder.apply
  end
  
  it "should save the response as a response for HTML in the :resourceful_responses inheritable_attribute" do
    responses = @controller.read_inheritable_attribute(:resourceful_responses)
    responses[:index].map(&:first).should == [:html]
    responses[:index].map(&:last).each(&:call)
  end
end
