require File.dirname(__FILE__) + '/../test_helper'
require 'things_controller'

# Re-raise errors caught by the controller.
class ThingsController; def rescue_action(e) raise e end; end

class ThingsControllerTest < Test::Unit::TestCase
  fixtures :things, :people

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

    assert_response :success
  end

  def test_show_bad_parent
    begin
      get :show,
        :id => 2,
        :person_id => 2
    rescue ActiveRecord::RecordNotFound => err
    end
    
    assert_not_nil err
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
    assert_equal 2, thing.person_id

    assert_equal 1, thing.user_id

    assert_equal thing, assigns(:thing)
    assert_equal thing.person, assigns(:person)
  end
end
