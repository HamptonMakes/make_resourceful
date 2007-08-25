require File.dirname(__FILE__) + '/../test_helper'
require 'parties_controller'

# Re-raise errors caught by the controller.
class PartiesController; def rescue_action(e) raise e end; end

class PartiesControllerTest < Test::Unit::TestCase
  fixtures :parties, :people, :parties_people

  def setup
    @controller = PartiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show_should_respond_to_xml
    show_test :xml
    assert_equal "application/xml; charset=utf-8", @response.headers['Content-Type']

    # Not guaranteed to work, hashes are unordered
    # assert_equal hash_for_fun_party.to_xml(:root => :party), @response.body
  end
  
  def test_show_should_respond_to_json
    show_test :json
    assert_equal "application/json; charset=utf-8", @response.headers['Content-Type']
    # Not guaranteed to work, hashes are unordered
    # assert_equal hash_for_fun_party.to_json, @response.body
  end
  
  def test_show_should_respond_to_yaml
    show_test :yaml
    assert_equal "application/x-yaml; charset=utf-8", @response.headers['Content-Type']
    assert_equal({'party' => hash_for_fun_party}, YAML.load(@response.body))
  end
  
  def test_index_should_not_respond_to_xml
    get :index, :format => "xml"
    assert_not_equal "application/x-yaml; charset=utf-8", @response.headers['Content-Type']
    assert_template 'index'
  end
    
  private

  def show_test(format)
    get :show, :id => parties(:fun_party).id, :format => format.to_s
    assert_response :success
  end
end
