class Admin::Blog::PostsController < ApplicationController
  make_resourceful do
    build :all
  end
end
