module IntegrationHelpers
  # Need this helper, because we made current_objects private
  def current_objects
    controller.instance_eval("current_objects")
  end

  # Need this helper, because we made current_object private
  def current_object
    controller.instance_eval("current_object")
  end
end