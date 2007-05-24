require File.dirname(__FILE__) + '/../test_helper'
require 'people_controller'

# Re-raise errors caught by the controller.
class PeopleController; def rescue_action(e) raise e end; end

class PeopleControllerTest < Test::Unit::TestCase
  def setup
    @controller = PeopleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create
    attributes = {:name => "Sam",
                  :age  => 24}
    post :create,
         :person => attributes

    assert_redirected_to person_path(Person.count)
    assert_not_nil Person.find_by_name(attributes[:name])
  end

  def test_create_with_custom_redirect
    attributes = {:name => "Sam",
                  :age  => 24}
    post :create,
         :person => attributes,
         :_redirect_on => {:success => "http://www.google.com"}

    assert_redirected_to "http://www.google.com"
    assert_not_nil Person.find_by_name(attributes[:name])
  end

  def test_create_with_custom_flash_notice
    attributes = {:name => "Sam",
                  :age  => 24}
    post :create,
         :person => attributes,
         :_flash => {:notice => "icanhascheezburger?"}

    assert_equal flash[:notice], "icanhascheezburger?"
    assert_nil flash[:error]
    assert_not_nil Person.find_by_name(attributes[:name])
  end

  def test_create_fails
    attributes = { :age => 100 }
    post :create,
         :person => attributes,
         :_flash => {:error => "icanhascheezburger?"}

    assert_equal flash[:error], "icanhascheezburger?"
    assert_nil flash[:notice]
    assert_nil Person.find_by_age(attributes[:age])

    assert_tag :tag => 'div', 
               :attributes => {:id => "errorExplanation"}

    assert_response :success
  end
end
