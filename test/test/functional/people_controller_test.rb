require File.dirname(__FILE__) + '/../test_helper'
require 'people_controller'

# Re-raise errors caught by the controller.
class PeopleController; def rescue_action(e) raise e end; end

class PeopleControllerTest < Test::Unit::TestCase
  fixtures :people

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

    assert_response 422
  end

  def test_show
    get :show,
        :id => 1

    assert_redirected_to person_path(people(:one))
    assert_equal people(:one), assigns(:person)
    assert_equal people(:one), assigns(:current_object)
    assert_not_nil assigns(:before_show_called)
  end
  
  def test_show_fails
    get :show, :id => 1982
    
    assert_response 404
  end

  def test_new
    get :new

    assert_response :success
    assert_not_nil assigns(:before_edit_and_new)
  end

  def test_edit
    get :edit,
        :id => 2

    assert_response :success
    assert_tag :tag => 'p', :child => "I am a custom edit for the person #{people(:two).name}"

    assert_equal people(:two), assigns(:current_object)
    assert_nil assigns(:person)

    assert_nil assigns(:before_edit_and_new)
  end

  def test_index_html
    get :index, :format => 'html'

    assert_response :success

    assert_kind_of Array, assigns(:people)
    assert assigns(:people).include?(people(:one))
    assert assigns(:people).include?(people(:two))

    assert_equal assigns(:people), assigns(:current_objects)
    
    assert_tag :content => "HTML"
  end

  def test_index_json
    get :index, :format => 'json'

    assert_response :success

    assert_kind_of Array, assigns(:people)
    assert assigns(:people).include?(people(:one))
    assert assigns(:people).include?(people(:two))

    assert_equal assigns(:people), assigns(:current_objects)

    assert_equal 'application/json; charset=utf-8', @response.headers['Content-Type']
    assert_tag :content => "JSON".to_json
  end

  def test_destroy
    person = people(:two)

    get :destroy,
        :id => 2,
        :format => 'json'

    assert_response :success
    assert_equal person, assigns(:person)

    begin
      Person.find(2)
    rescue ActiveRecord::RecordNotFound => err
    end

    assert_not_nil err

    assert_equal 'application/json; charset=utf-8', @response.headers['Content-Type']
    assert_tag :content => "JSON".to_json
  end

  def test_should_be_plural
    assert @controller.plural?
    assert !@controller.singular?
  end
end
