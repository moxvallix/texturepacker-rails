Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :dashboard do
    collection do
      post 'upload'
      post 'model'
      post 'search'
      post 'selection'
      get 'download'
      get 'output'
      get 'edit'
    end
  end
  root 'dashboard#index'
end
