require 'test/loader'


class AccessorsTest < Test::Unit::TestCase

  def setup
    @empty_controller = EmptyControllers::UsersController.new
    @simple_controller = SimpleControllers::UsersController.new
  end
  
  # Find out if we can devine the proper ActiveRecord-style class name from the Controller
  def test_current_model
    assert_equal User, send_controller(:current_model)
  end

  # Does the current_objects method behave as we'd assume
  def test_current_objects
    assert_instance_of Array, send_controller(:current_objects, :empty)
    assert_instance_of User,  send_controller(:current_objects, :empty).first
  end

  # Does current_object behave as expected?
  def test_current_object
    assert_instance_of User,  send_controller(:current_object, :empty)
    assert_equal       82,    send_controller(:current_object, :empty).id
  end

  def test_current_param
    assert_equal      "82",   send_controller(:current_param, :empty)
  end

  # model_includes should by default return an empty hash
  def test_empty_model_includes
    assert_equal Hash.new,    send_controller(:model_includes, :empty)
  end

  private
    def send_controller(method_name, type = :simple)
      eval("@#{type}_controller.instance_eval(method_name.to_s)")
    end
end
