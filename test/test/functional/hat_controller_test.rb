require File.dirname(__FILE__) + '/../test_helper'
require 'hat_controller'

# Re-raise errors caught by the controller.
class HatController; def rescue_action(e) raise e end; end

class HatControllerTest < Test::Unit::TestCase
  fixtures :hats, :users

  def setup
    @controller = HatController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_be_singular
    assert !@controller.plural?
    assert @controller.singular?
  end

  def test_shouldnt_respond_to_index
    assert_raise(ActionController::UnknownAction) { get :index, :user_id => 2 }
  end

  def test_should_get_current_object_from_parent
    get :show, :user_id => 2

    assert_response :success
    assert_equal hats(:sombrero), assigns(:current_object)
  end
end
