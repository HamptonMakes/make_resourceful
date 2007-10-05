require File.dirname(__FILE__) + '/spec_helper'

describe Resourceful::Default::URLs, " for a controller with no parents or namespaces" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::URLs
    @model = stub_model('Thing')
    @controller.stubs(:current_object).returns(@model)
    
    @controller.stubs(:current_model_name).returns('Thing')
    @controller.stubs(:parent_objects).returns([])
    @controller.stubs(:namespaces).returns([])
  end

  it "should get the path of current_object with #object_path" do
    @controller.expects(:send).with('thing_path', @model)
    @controller.object_path
  end

  it "should get the url of current_object with #object_url" do
    @controller.expects(:send).with('thing_url', @model)
    @controller.object_url
  end

  it "should get the path of the passed object with #object_path" do
    model = stub_model('Thing')
    @controller.expects(:send).with('thing_path', model)
    @controller.object_path(model)
  end

  it "should get the url of the passed object with #object_url" do
    model = stub_model('Thing')
    @controller.expects(:send).with('thing_url', model)
    @controller.object_url(model)
  end

  it "should get the edit path of current_object with #edit_object_path" do
    @controller.expects(:send).with('edit_thing_path', @model)
    @controller.edit_object_path
  end

  it "should get the edit url of current_object with #edit_object_url" do
    @controller.expects(:send).with('edit_thing_url', @model)
    @controller.edit_object_url
  end

  it "should get the edit path of the passed object with #edit_object_path" do
    model = stub_model('Thing')
    @controller.expects(:send).with('edit_thing_path', model)
    @controller.edit_object_path(model)
  end

  it "should get the edit url of the passed object with #edit_object_url" do
    model = stub_model('Thing')
    @controller.expects(:send).with('edit_thing_url', model)
    @controller.edit_object_url(model)
  end

  it "should get the plural path of the current model with #objects_path" do
    @controller.expects(:send).with('things_path')
    @controller.objects_path
  end

  it "should get the plural url of the current model with #objects_url" do
    @controller.expects(:send).with('things_url')
    @controller.objects_url
  end

  it "should get the new path of the current model with #new_object_path" do
    @controller.expects(:send).with('new_thing_path')
    @controller.new_object_path
  end

  it "should get the new url of the current model with #new_object_url" do
    @controller.expects(:send).with('new_thing_url')
    @controller.new_object_url
  end
end

describe Resourceful::Default::URLs, " for a controller with several parents" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::URLs
    @model = stub_model('Thing')
    @controller.stubs(:current_object).returns(@model)
    
    @controller.stubs(:current_model_name).returns('Thing')

    @parent = stub_model('Parent')
    @gandparent = stub_model('GrandParent')
    @controller.stubs(:parent_objects).returns([@grandparent, @parent])
    @controller.stubs(:namespaces).returns([])
  end

  it "should get the path of current_object and its parents with #object_path" do
    @controller.expects(:send).with('thing_path', @grandparent, @parent, @model)
    @controller.object_path
  end

  it "should get the plural path of the current model and parents with #objects_path" do
    @controller.expects(:send).with('things_path', @grandparent, @parent)
    @controller.objects_path
  end
end

describe Resourceful::Default::URLs, " for a controller within a namespace" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::URLs
    @model = stub_model('Thing')
    @controller.stubs(:current_object).returns(@model)
    
    @controller.stubs(:current_model_name).returns('Thing')

    @controller.stubs(:parent_objects).returns([])
    @controller.stubs(:namespaces).returns([:admin, :main])
  end

  it "should get the namespaced path of current_object with #object_path" do
    @controller.expects(:send).with('admin_main_thing_path', @model)
    @controller.object_path
  end

  it "should get the namespaced plural path of the current model with #objects_path" do
    @controller.expects(:send).with('admin_main_things_path')
    @controller.objects_path
  end
end
