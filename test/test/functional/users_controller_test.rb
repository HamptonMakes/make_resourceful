require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_have_index_action
    get :index
    assert_response :success
  end

  def test_index_should_set_users
    get :index

    users = @controller.instance_variable_get('@users')
    assert_kind_of Array, users
    assert users.include?(users(:hampton))
    assert users.include?(users(:jeff))
  end

  def test_view_should_see_users
    get :index

    assert_tag :tag => 'h1', :content => users(:hampton).first_name
    assert_tag :tag => 'h1', :content => users(:jeff).first_name
  end

  def test_magic_is_not_visible
    get :magic

    # If the method were visible, an exception would have been raised
    assert_response :success
  end

  def test_show
    id = 3
    get :show, :id => id

    assert_equal assigns(:user).id, id
    assert_tag :tag => 'h5', :content => users(:nathan).first_name
  end
  
  def test_destroy_fails
    #so it doesn't cry about redirect_to :back
    @request.env["HTTP_REFERER"] = "www.google.com"
    
    u = users(:indestructible_user)
    delete :destroy, :id => u.id
    
    assert_not_nil User.find_by_id(u.id), 'should not have deleted indestructible_user'
  end
  
end
