require File.dirname(__FILE__) + '/../test_helper'
require 'things_controller'

# Re-raise errors caught by the controller.
class ThingsController; def rescue_action(e) raise e end; end

class ThingsControllerTest < Test::Unit::TestCase
  fixtures :things, :people, :users

  def setup
    @controller = ThingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    get :show,
        :id => 2,
        :person_id => 1

    assert_equal things(:house), assigns(:thing)
    assert_equal people(:one), assigns(:person)
    assert_equal people(:one), assigns(:thing).person

    assert_tag :tag => 'a', :content => 'obj', :attributes => {:href => thing_path(people(:one))}
    assert_tag :tag => 'a', :content => 'objs', :attributes => {:href => things_path(people(:one))}
    assert_tag :tag => 'a', :content => 'new_obj', :attributes => {:href => new_thing_path(people(:one))}
    assert_tag :tag => 'a', :content => 'edit_obj', :attributes => {:href => edit_thing_path(people(:one), things(:house))}

    assert_response :success
  end

  def test_show_bad_parent
    get :show,
      :id => 2,
      :person_id => 2
    
    assert_response 404
  end

  def test_create
    post :create,
        :person_id => 2,
        :thing => {
           :name => "nillawafer",
           :awesome => true
        }

    assert_not_nil (thing = Thing.find_by_name("nillawafer"))
    assert_redirected_to thing_path(thing.person, thing)
    assert_equal people(:two), thing.person

    assert_equal users(:jeff), thing.user

    assert_equal thing, assigns(:thing)
    assert_equal thing.person, assigns(:person)
  end

  def test_preview
    get :preview,
        :person_id => 1,
        :thing => {
          :name => 'mud',
          :awesome => false
        }

    assert :success
    assert_equal people(:one), assigns(:current_object).person
    assert_tag :content => 'mud'
  end

  def test_update
    get :update,
        :person_id => 1,
        :id => 2,
        :format => 'js',
        :thing => { :name => 'bubbles' }

    assert :success
    assert_equal 'bubbles', assigns(:thing).name
    assert_tag :content => '$("foobar").show();'
    assert assigns(:save_succeeded)
  end

  def test_update_fails
    get :update,
        :person_id => 1,
        :id => 2,
        :format => 'js',
        :thing => { :name => ('*' * 42) }

    assert :failure
    assert (false === assigns(:save_succeeded))
  end
end
