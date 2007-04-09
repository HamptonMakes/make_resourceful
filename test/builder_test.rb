require 'test/loader'


class AccessorsTest < Test::Unit::TestCase

  def setup
    @controller = UsersController.new
  end
  
  # Find out if we can devine the proper ActiveRecord-style class name from the Controller
  def test_current_model
    assert_equal User, send_controller(:current_model)
  end

  # Does the current_objects method behave as we'd assume
  def test_current_objects
    assert_instance_of Array, send_controller(:current_objects)
    assert_instance_of User,  send_controller(:current_objects).first
  end

  # Does current_object behave as expected?
  def test_current_object
    assert_instance_of User,  send_controller(:current_object)
    assert_equal       82,    send_controller(:current_object).id
  end

  def test_current_param
    assert_equal      "82",   send_controller(:current_param)
  end

  # model_includes should by default return an empty hash
  def test_empty_model_includes
    assert_equal Hash.new,    send_controller(:model_includes)
  end

  private
    def send_controller(method_name)
      @controller.instance_eval(method_name.to_s)
    end
end
