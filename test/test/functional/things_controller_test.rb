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

  # Replace this with your real tests.
  def test_show
    get :show,
        :id => 2,
        :person_id => 1

    assert assigns(:thing)
    assert assigns(:person)

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

    assert_not_nil assigns(:thing)
    assert_not_nil assigns(:person)

    assert_not_nil (thing = Thing.find_by_name("nillawafer"))
    assert_redirect_to thing_path(thing.person, thing)
    assert_equal 2, thing.person_id
  end
end
