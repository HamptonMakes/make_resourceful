require File.dirname(__FILE__) + '/../../../test_helper'
require 'admin/blog/posts_controller'

# Re-raise errors caught by the controller.
class Admin::Blog::PostsController; def rescue_action(e) raise e end; end

class Admin::Blog::PostsControllerTest < Test::Unit::TestCase
  fixtures :posts

  def setup
    @controller = Admin::Blog::PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create
    attributes = {:title => 'My fascinating cat',
                  :body  => 'Here are a thousand pictures of my cat.'}
    post :create,
         :post => attributes

    assert_redirected_to admin_blog_post_path(Post.count)
    assert_not_nil Post.find_by_title(attributes[:title])
    assert_equal [:admin, :blog], assigns(:namespaces)
  end

  def test_destroy
    post = posts(:second)
    
    get :destroy,
        :id => 2
    
    assert_redirected_to admin_blog_posts_path
    assert_equal post, assigns(:post)
    
    begin
      Post.find(2)
    rescue ActiveRecord::RecordNotFound => err
    end
    
    assert_not_nil err
  end
end
