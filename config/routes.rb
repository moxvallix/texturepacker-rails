Rails.application.routes.draw do
  resources :textures
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :dashboard do
    collection do
      post 'upload'
      post 'search'
      post 'selection'
    end
  end
  root 'textures#index'
end
