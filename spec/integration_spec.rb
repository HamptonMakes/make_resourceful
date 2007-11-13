require File.dirname(__FILE__) + '/spec_helper'

describe "ThingsController", "with all the resourceful actions" do
  include RailsMocks
  inherit Test::Unit::TestCase
  before :each do
    mock_resourceful do
      actions :all
    end
    @objects = stub_list(5, 'Thing') do |t|
      [:destroy, :save, :update_attributes].each { |m| t.stubs(m).returns(true) }
      t.stubs(:to_param).returns('12')
    end
    @object = @objects.first
    Thing.stubs(:find).returns(@object)
    Thing.stubs(:new).returns(@object)
  end

  ## Default responses

  (Resourceful::ACTIONS - Resourceful::MODIFYING_ACTIONS).each(&method(:should_render_html))
  Resourceful::ACTIONS.each(&method(:should_render_js))
  Resourceful::ACTIONS.each(&method(:shouldnt_render_xml))

  ## Specs for #index

  it "should find all records on GET /things" do
    Thing.expects(:find).with(:all).returns(@objects)
    get :index
  end

  it "should return a list of objects for #current_objects after GET /things" do
    Thing.stubs(:find).returns(@objects)
    get :index
    controller.current_objects.should == @objects
  end

  it "should assign @things to a list of objects for GET /things" do
    Thing.stubs(:find).returns(@objects)
    get :index
    assigns(:things).should == @objects
  end

  ## Specs for #show

  it "should find the record with id 12 on GET /things/12" do
    Thing.expects(:find).with('12').returns(@object)
    get :show, :id => 12
  end

  it "should return an object for #current_object after GET /things/12" do
    Thing.stubs(:find).returns(@object)
    get :show, :id => 12
    controller.current_object.should == @object
  end

  it "should assign @thing to an object for GET /things/12" do
    Thing.stubs(:find).returns(@object)
    get :show, :id => 12
    assigns(:thing).should == @object
  end  

  ## Specs for #edit

  it "should find the record with id 12 on GET /things/12/edit" do
    Thing.expects(:find).with('12').returns(@object)
    get :edit, :id => 12
  end

  it "should return an object for #current_object after GET /things/12/edit" do
    Thing.stubs(:find).returns(@object)
    get :edit, :id => 12
    controller.current_object.should == @object
  end

  it "should assign @thing to an object for GET /things/12/edit" do
    Thing.stubs(:find).returns(@object)
    get :edit, :id => 12
    assigns(:thing).should == @object
  end

  ## Specs for #new

  it "should create a new object from params[:thing] for GET /things/new" do
    Thing.expects(:new).with('name' => "Herbert the thing").returns(@object)
    get :new, :thing => {:name => "Herbert the thing"}
  end

  it "should create a new object even if there aren't any params for GET /things/new" do
    Thing.expects(:new).with(nil).returns(@object)
    get :new
  end

  it "should return the new object for #current_object after GET /things/new" do
    Thing.stubs(:new).returns(@object)
    get :new
    controller.current_object.should == @object
  end

  it "should assign @thing to the new object for GET /things/new" do
    Thing.stubs(:new).returns(@object)
    get :new
    assigns(:thing).should == @object
  end

  ## Specs for #create

  it "should create a new object from params[:thing] for POST /things" do
    Thing.expects(:new).with('name' => "Herbert the thing").returns(@object)
    post :create, :thing => {:name => "Herbert the thing"}
  end

  it "should create a new object even if there aren't any params for POST /things" do
    Thing.expects(:new).with(nil).returns(@object)
    post :create
  end

  it "should return the new object for #current_object after POST /things" do
    Thing.stubs(:new).returns(@object)
    post :create
    controller.current_object.should == @object
  end

  it "should assign @thing to the new object for POST /things" do
    Thing.stubs(:new).returns(@object)
    post :create
    assigns(:thing).should == @object
  end

  it "should save the new object for POST /things" do
    Thing.stubs(:new).returns(@object)
    @object.expects(:save)
    post :create
  end

  it "should set an appropriate flash notice for a successful POST /things" do
    Thing.stubs(:new).returns(@object)
    post :create
    flash[:notice].should == "Create successful!"
  end

  it "should redirect to the new object for a successful POST /things" do
    Thing.stubs(:new).returns(@object)
    post :create
    response.should redirect_to('/things/12')
  end

  it "should set an appropriate flash error for an unsuccessful POST /things" do
    Thing.stubs(:new).returns(@object)
    @object.stubs(:save).returns(false)
    post :create
    flash[:error].should == "There was a problem!"
  end

  it "should give a failing response for an unsuccessful POST /things" do
    Thing.stubs(:new).returns(@object)
    @object.stubs(:save).returns(false)
    post :create
    response.should_not be_success
    response.code.should == '422'
  end

  it "should render the #new template for an unsuccessful POST /things" do
    Thing.stubs(:new).returns(@object)
    @object.stubs(:save).returns(false)
    post :create
    response.should render_template('new')
  end
end
