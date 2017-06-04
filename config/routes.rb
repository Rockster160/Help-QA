Rails.application.routes.draw do
  root to: 'index#index'

  get :flash_message, controller: "application"

  devise_for :users, path: "account"

  resources :posts, except: [ :destroy ]
  get "tags/:tag_name" => "tags#show", as: :tag
  resources :tags, only: [ :index ]
  resources :users, except: [ :destroy ]

end
