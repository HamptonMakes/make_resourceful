ActionController::Routing::Routes.draw do |map|
  map.resources :users do |user|
    user.resource :hat
  end

  map.resources :people do |person|
     person.resources :things do |thing|
      thing.resources :properties
    end
  end
  
  map.resources :parties

  # In Edge Rails (changeset 6783):
  #   map.namespace :admin do |admin|
  #     admin.namespace :blog do |blog|
  #       blog.resources :pages
  #     end
  #   end
  map.resources :posts, :controller => 'admin/blog/posts',
    :path_prefix => '/admin/blog', :name_prefix => 'admin_blog_'

  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
