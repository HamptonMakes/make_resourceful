require File.dirname(__FILE__) + '/spec_helper'

describe "ThingsController", "with all the resourceful actions" do
  include RailsMocks
  inherit Test::Unit::TestCase
  before :each do
    mock_resourceful do
      actions :all
    end
    @object = stub('Thing')
    @objects = stub_list(5, 'Thing')
    Thing.stubs(:find).returns(@object)
  end

  it "should find all records on GET /things" do
    Thing.expects(:find).with(:all).returns(@objects)
    post :index
  end

  it "should return a list of objects for #current_object after GET /things" do
    Thing.stubs(:find).returns(@objects)
    post :index
    controller.current_objects.should == @objects
  end

  it "should assign @things to a list of objects for GET /things" do
    Thing.stubs(:find).returns(@objects)
    post :index
    assigns(:things).should == @objects
  end

  it "should render HTML by default for GET /things" do
    post :index
    response.should be_success
    response.content_type.should == 'text/html'
  end

  it "should render JS for GET /things" do
    post :index, :format => 'js'
    response.should be_success
    response.content_type.should == 'text/javascript'
  end

  it "shouldn't render XML for GET /things" do
    post :index, :format => 'xml'
    response.should_not be_success
    response.code.should == '406'
  end
end
