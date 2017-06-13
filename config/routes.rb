Rails.application.routes.draw do
  root to: 'index#index'

  get :flash_message, controller: "application"

  devise_for :users, path: "account"

  resources :posts, except: [ :destroy ] do
    post :report
  end
  get "tags/:tag_name" => "tags#show", as: :tag
  resources :tags, only: [ :index ]
  resources :users, except: [ :destroy ] do
    get :shoutbox
    resources :posts
    resources :replies
  end

end
