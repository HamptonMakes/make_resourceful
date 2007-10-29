require File.dirname(__FILE__) + '/spec_helper'

describe Resourceful::Default::Accessors, "#current_objects" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @objects = Array.new(5) { stub }
    @model = stub
    @controller.stubs(:current_model).returns(@model)
  end

  it "should look up all objects in the current model" do
    @model.expects(:find).with(:all).returns(@objects)
    @controller.current_objects.should == @objects
  end

  it "should cache the result, so subsequent calls won't run multiple queries" do
    @model.expects(:find).once.returns(@objects)
    @controller.current_objects
    @controller.current_objects
  end

  it "shouldn't run a query if @current_objects is set" do
    @controller.instance_variable_set('@current_objects', @objects)
    @model.expects(:find).never
    @controller.current_objects.should == @objects
  end
end

describe Resourceful::Default::Accessors, "#load_objects" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @objects = Array.new(5) { stub }
    @controller.stubs(:current_objects).returns(@objects)
    @controller.stubs(:instance_variable_name).returns("posts")
  end

  it "should set the current instance variable to the object collection" do
    @controller.load_objects
    @controller.instance_variable_get('@posts').should == @objects
  end
end

describe Resourceful::Default::Accessors, "#current_object on a plural controller" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:plural?).returns(true)
    @controller.stubs(:instance_variable_name).returns("posts")
    @controller.stubs(:params).returns(:id => "12")

    @object = stub
    @model = stub
    @controller.stubs(:current_model).returns(@model)
  end

  it "should look up the object specified by the :id parameter in the current model" do
    @model.expects(:find).with('12').returns(@object)
    @controller.current_object.should == @object
  end

  it "should cache the result, so subsequent calls won't run multiple queries" do
    @model.expects(:find).once.returns(@object)
    @controller.current_object
    @controller.current_object
  end

  it "shouldn't run a query if @current_object is set" do
    @controller.instance_variable_set('@current_object', @object)
    @model.expects(:find).never
    @controller.current_object.should == @object
  end
end

describe Resourceful::Default::Accessors, "#current_object on a singular controller" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:plural?).returns(false)
    @controller.stubs(:instance_variable_name).returns("post")

    @parents = Array.new(5) { stub }
    @controller.stubs(:parent_objects).returns(@parents)

    @object = stub
  end

  it "should look up the instance object of the last parent object" do
    @parents[-1].expects(:post).returns(@object)
    @controller.current_object.should == @object
  end
end

describe Resourceful::Default::Accessors, "#load_object" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @object = stub
    @controller.stubs(:current_object).returns(@object)
    @controller.stubs(:instance_variable_name).returns("posts")
  end

  it "should set the current singular instance variable to the current object" do
    @controller.load_object
    @controller.instance_variable_get('@post').should == @object
  end
end

describe Resourceful::Default::Accessors, "#build_object with a #build-able model" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @params = {:name => "Bob", :password => "hideously insecure"}
    @controller.stubs(:object_parameters).returns(@params)

    @object = stub
    @model = stub
    @controller.stubs(:current_model).returns(@model)

    @model.stubs(:build).returns(@object)
  end

  it "should return a new object built with current_model from the object parameters" do
    @model.expects(:build).with(@params).returns(@object)
    @controller.build_object.should == @object
  end

  it "should make current_object return the newly built object" do
    @controller.build_object
    @controller.current_object.should == @object
  end
end

describe Resourceful::Default::Accessors, "#build_object with a non-#build-able model" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @params = {:name => "Bob", :password => "hideously insecure"}
    @controller.stubs(:object_parameters).returns(@params)

    @object = stub
    @model = stub
    @controller.stubs(:current_model).returns(@model)

    @model.stubs(:new).returns(@object)
  end

  it "should return a new instance of the current_model built with the object parameters" do
    @model.expects(:new).with(@params).returns(@object)
    @controller.build_object.should == @object
  end
end

describe Resourceful::Default::Accessors, "#current_model_name" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:controller_name).returns("funky_posts")
  end

  it "should return the controller's name, singularized and camel-cased" do
    @controller.current_model_name.should == "FunkyPost"
  end
end

describe Resourceful::Default::Accessors, "#namespaces" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @kontroller.stubs(:name).returns("FunkyStuff::Admin::Posts")
  end

  it "should return an array of underscored symbols representing the namespaces of the controller class" do
    @controller.namespaces.should == [:funky_stuff, :admin]
  end

  it "should cache the result, so subsequent calls won't run multiple computations" do
    @kontroller.expects(:name).once.returns("Posts")
    @controller.namespaces
    @controller.namespaces
  end
end

describe Resourceful::Default::Accessors, "#instance_variable_name" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:controller_name).returns("posts")
  end
  
  it "should return controller_name" do
    @controller.instance_variable_name == "posts"
  end
end

describe Resourceful::Default::Accessors, "#current_model for a singular controller" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:singular?).returns(true)
    @controller.stubs(:current_model_name).returns("Resourceful")

    @parents = Array.new(5) { stub }
    @controller.stubs(:parent_objects).returns(@parents)
  end
  
  it "should return the constant named by current_model_name" do
    @controller.current_model.should == Resourceful
  end
end

describe Resourceful::Default::Accessors, "#current_model for a plural controller with no parents" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:singular?).returns(false)
    @controller.stubs(:current_model_name).returns("Resourceful")
    @controller.stubs(:parent_objects).returns([])
  end
  
  it "should return the constant named by current_model_name" do
    @controller.current_model.should == Resourceful
  end
end

describe Resourceful::Default::Accessors, "#current_model for a plural controller with parents" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:singular?).returns(false)
    @controller.stubs(:instance_variable_name).returns("posts")

    @model = stub
    @parents = Array.new(5) { stub }
    @controller.stubs(:parent_objects).returns(@parents)
  end
  
  it "should return the parent-scoped model" do
    @parents[-1].stubs(:posts).returns(@model)
    @controller.current_model.should == @model
  end
end


