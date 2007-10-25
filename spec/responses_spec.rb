require File.dirname(__FILE__) + '/spec_helper'

describe 'Resourceful::Default::Responses', " with a _flash parameter for :error" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Responses
    @flash = {}
    @controller.stubs(:flash).returns(@flash)
    @params = {:_flash => {:error => 'Oh no, an error!'}}
    @controller.stubs(:params).returns(@params)
  end

  it "should set the flash for :error to the parameter's value when set_default_flash is called on :error" do
    @controller.set_default_flash(:error, "Aw there's no error!")
    @flash[:error].should == 'Oh no, an error!'
  end

  it "should set the flash for :message to the default value when set_default_flash is called on :message" do
    @controller.set_default_flash(:message, "All jim dandy!")
    @flash[:message].should == 'All jim dandy!'
  end

  it "shouldn't set the flash for :error when set_default_flash is called on :message" do
    @controller.set_default_flash(:message, "All jim dandy!")
    @flash[:error].should be_nil
  end
end

describe 'Resourceful::Default::Responses', " with a _redirect parameter on :failure" do
  include ControllerMocks
  before :each do
    mock_controller Resourceful::Default::Responses
    @params = {:_redirect_on => {:failure => 'http://hamptoncatlin.com/'}}
    @controller.stubs(:params).returns(@params)
  end

  it "should set the redirect for :failure to the parameter's value when set_default_redirect is called on :failure" do
    @controller.expects(:redirect_to).with('http://hamptoncatlin.com/')
    @controller.set_default_redirect(:back, :on => :failure)
  end

  it "should set the redirect for :success to the default value when set_default_redirect is called on :success" do
    @controller.expects(:redirect_to).with(:back)
    @controller.set_default_redirect(:back, :on => :success)
  end

  it "shouldn't set the redirect for :failure when set_default_redirect is called on :success" do
    @controller.expects(:redirect_to).with(:back)
    @controller.expects(:redirect_to).with('http://hamptoncatlin.com/').never
    @controller.set_default_redirect(:back, :on => :success)
  end

  it "should set the default redirect for :success by default" do
    @controller.expects(:redirect_to).with(:back)
    @controller.set_default_redirect(:back)
  end
end
