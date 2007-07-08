require File.dirname(__FILE__) + '/../test_helper'
require 'properties_controller'

# Re-raise errors caught by the controller.
class PropertiesController; def rescue_action(e) raise e end; end

class PropertiesControllerTest < Test::Unit::TestCase
  fixtures :things, :people, :properties

  def setup
    @controller = PropertiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    get(:show,
        :id => 1,
        :thing_id => 1,
        :person_id => 1)

    assert_response :success

    assert_equal properties(:blueness), assigns(:property)
    assert_equal things(:car), assigns(:thing)
    assert_equal things(:car), assigns(:property).thing
    assert_equal people(:one), assigns(:person)
    assert_equal people(:one), assigns(:thing).person
  end

  def test_show_bad_parent
    get :show,
      :id => 1,
      :thing_id => 2,
      :person_id => 1
    
    assert_response 404
  end

  def test_show_bad_grandparent
    begin
      get :show,
        :id => 1,
        :thing_id => 1,
        :person_id => 2
    rescue ActiveRecord::RecordNotFound => err
    end
    
    assert_not_nil err    
  end

  def test_create
    post :create,
        :thing_id => 3,
        :person_id => 2,
        :property => {:name => "bubbly"}

    assert_not_nil (prop = Property.find_by_name("bubbly"))
    assert_redirected_to property_path(prop.thing.person, prop.thing, prop)
    assert_equal 3, prop.thing_id
    assert_equal 2, prop.thing.person_id

    assert_equal prop, assigns(:property)
    assert_equal prop.thing, assigns(:thing)
    assert_equal prop.thing.person, assigns(:person)
  end

  def test_create_with_bad_grandparent
    begin
      post :create,
           :thing_id => 2,
           :person_id => 2,
           :property => {:name => "grunky"}
    rescue ActiveRecord::RecordNotFound => err
    end

    assert_not_nil err
  end
end
