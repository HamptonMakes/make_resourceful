module HelperMethods
  def should_render_html(action)
    it "should render HTML by default for #{action_string(action)}" do
      action_method(action)[action, action_params(action)]
      response.body.should include("as HTML")
      response.content_type.should == 'text/html'
    end
  end

  def should_render_js(action)
    it "should render JS for #{action_string(action)}" do
      action_method(action)[action, action_params(action, :format => 'js')]
      response.body.should include("insert(\"#{action}")
      response.should be_success
      response.content_type.should == 'text/javascript'
    end
  end

  def shouldnt_render_xml(action)
    it "shouldn't render XML for #{action_string(action)}" do
      action_method(action)[action, action_params(action, :format => 'xml')]
      response.should_not be_success
      response.code.should == '406'
    end
  end

  def action_string(action)
    case action
    when :index, "GET /things"
    when :show, "GET /things/12"
    when :edit, "GET /things/12/edit"
    when :update, "PUT /things/12"
    when :create, "POST /things"
    when :new, "GET /things/new"
    when :destroy, "DELETE /things/12"
    end
  end
end