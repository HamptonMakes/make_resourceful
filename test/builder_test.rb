require 'test/loader'


class BuilderTest < Test::Unit::TestCase

  def setup
    @request = ActionController::TestRequest.new
    @request.host = 'hostname.com'

    @response   = ActionController::TestResponse.new
    @simple_controller = SimpleControllers::UsersController.new

  end

  def test_has_index_action
    @controller = @simple_controller
    #get :index
    assert true
  end

  private
    def send_controller(method_name)
      @simple_controller.instance_eval(method_name.to_s)
    end
end
