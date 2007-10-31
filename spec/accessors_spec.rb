require File.dirname(__FILE__) + '/spec_helper'

describe Resourceful::Default::Accessors, "#current_objects" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @objects = stub_list 5, 'object'
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
    @objects = stub_list 5, 'object'
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

    @parents = stub_list 5, 'parent'
    @controller.stubs(:parent_objects).returns(@parents)

    @object = stub
  end

  it "should look up the instance object of the last parent object" do
    @parents[-1].expects(:post).returns(@object)
    @controller.current_object.should == @object
  end
end

describe Resourceful::Default::Accessors, "#current_object on a plural controller with current_param defined" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:plural?).returns(true)
    @controller.stubs(:current_param).returns("12")

    @object = stub
    @model = stub
    @controller.stubs(:current_model).returns(@model)
  end

  it "should look up the object specified by #current_param, but issue a deprecation warning" do
    STDERR.expects(:puts).with(regexp_matches(/^DEPRECATION WARNING: /))

    @model.expects(:find).with("12").returns(@object)
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
    stub_const :Post
    @controller.stubs(:singular?).returns(true)
    @controller.stubs(:current_model_name).returns("Post")

    @parents = stub_list 5, 'parent'
    @controller.stubs(:parent_objects).returns(@parents)
  end
  
  it "should return the constant named by current_model_name" do
    @controller.current_model.should == Post
  end
end

describe Resourceful::Default::Accessors, "#current_model for a plural controller with no parents" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    stub_const :Post
    @controller.stubs(:singular?).returns(false)
    @controller.stubs(:current_model_name).returns("Post")
    @controller.stubs(:parent_objects).returns([])
  end
  
  it "should return the constant named by current_model_name" do
    @controller.current_model.should == Post
  end
end

describe Resourceful::Default::Accessors, "#current_model for a plural controller with parents" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:singular?).returns(false)
    @controller.stubs(:instance_variable_name).returns("posts")

    @model = stub
    @parents = stub_list 5, 'parent'
    @controller.stubs(:parent_objects).returns(@parents)
  end
  
  it "should return the parent-scoped model" do
    @parents[-1].stubs(:posts).returns(@model)
    @controller.current_model.should == @model
  end
end

describe Resourceful::Default::Accessors, "#object_parameters" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @params = {"crazy_user" => {:name => "Hampton", :location => "Canada"}}
    @controller.stubs(:params).returns(@params)
    @controller.stubs(:current_model_name).returns("CrazyUser")
  end

  it "should return the element of the params hash with the name of the model" do
    @controller.object_parameters.should == @params["crazy_user"]
  end
end

describe Resourceful::Default::Accessors, "#response_for" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
  end

  it "should send the method response_for_action" do
    @controller.expects(:response_for_index)
    @controller.response_for :index
  end
end

describe Resourceful::Default::Accessors, " with five parent classes set on the controller class" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @parents = %w{big_page page post comment paragraph}
    @models = @parents.map(&:camelize).map(&method(:stub_const))
    @kontroller.write_inheritable_attribute(:parents, @parents)

    @params = {'big_page_id' => 10, 'page_id' => 11, 'post_id' => 12,
      'comment_id' => 13, 'paragraph_id' => 14}
    @controller.stubs(:params).returns(@params)

    @objects = stub_list 5, 'object'
    @models[0].stubs(:find).once.with(10).returns(@objects.first)
    [:pages, :posts, :comments, :paragraphs].zip((11..14).to_a, (1..4).to_a) do
        |method, key, index|
      @objects[index - 1].stubs(method).once.returns(@models[index])
      @models[index].stubs(:find).once.with(key).returns(@objects[index])
    end
  end

  it "should return the parents for #parents" do
    @controller.parents.should == @parents
  end

  it "should return the camelized model names for #parent_model_names" do
    @controller.parent_model_names.should == %w{BigPage Page Post Comment Paragraph}
  end

  it "should return the parameters for each parent for #parent_params" do
    @controller.parent_params.should == [10, 11, 12, 13, 14]
  end

  it "should return the model classes for #parent_models" do
    @controller.parent_models.should == [BigPage, Page, Post, Comment, Paragraph]
  end

  it "should return an array of parent objects looked up with their respective params scoped by their parents" do
    @models[0].expects(:find).with(10).returns(@objects.first)
    [:pages, :posts, :comments, :paragraphs].zip((11..14).to_a, (1..4).to_a) do
        |method, key, index|
      @objects[index - 1].expects(method).returns(@models[index])
      @models[index].expects(:find).with(key).returns(@objects[index])
    end
    @controller.parent_objects.should == @objects
  end

  it "should cache the value of #parent_objects so multiple calls won't cause multiple queries" do
    @models[0].expects(:find).returns(@objects.first).once
    @controller.parent_objects
    @controller.parent_objects
  end

  it "should bind the parent objects to their respective instance variables" do
    @controller.load_parent_objects
    ['big_page', 'page', 'post', 'comment', 'paragraph'].each_with_index do |var, i|
      @controller.instance_variable_get("@#{var}").should == @objects[i]
    end
  end
end

describe Resourceful::Default::Accessors, " with no parents" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:parents).returns([])
  end

  it "should return [] for #parent_objects" do
    @controller.parent_objects.should == []
  end
end

describe Resourceful::Default::Accessors, "#save_succeeded!" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.save_succeeded!
  end

  it "should make #save_succeeded? return true" do
    @controller.save_succeeded?.should be_true
  end
end

describe Resourceful::Default::Accessors, "#save_failed!" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.save_failed!
  end

  it "should make #save_succeeded? return false" do
    @controller.save_succeeded?.should be_false
  end
end

describe Resourceful::Default::Accessors, " for a plural action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:params).returns :action => "index"
  end

  it "should know it's a plural action" do
    @controller.should be_a_plural_action
  end

  it "should know it's not a singular action" do
    @controller.should_not be_a_singular_action
  end
end

describe Resourceful::Default::Accessors, " for a singular action" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:params).returns :action => "show"
  end

  it "should know it's not a plural action" do
    @controller.should_not be_a_plural_action
  end

  it "should know it's a singular action" do
    @controller.should be_a_singular_action
  end
end

describe Resourceful::Default::Accessors, " for a singular controller" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:instance_variable_name).returns "post"
  end

  it "should know it's not plural" do
    @controller.should_not be_plural
  end

  it "should know it's singular" do
    @controller.should be_singular
  end
end

describe Resourceful::Default::Accessors, " for a plural controller" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Accessors
    @controller.stubs(:instance_variable_name).returns "posts"
  end

  it "should know it's plural" do
    @controller.should be_plural
  end

  it "should know it's not singular" do
    @controller.should_not be_singular
  end
end
