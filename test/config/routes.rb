ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resources :people do |person|
    person.resources :things do |thing|
      thing.resources :properties
    end
  end

  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
