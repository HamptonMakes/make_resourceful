ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resources :people do |person|
    person.resources :things
  end

  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
