Rails.application.routes.draw do
  root to: 'index#index'

  get :flash_message, controller: "application"

  devise_for :users, path: "account"

  resources :posts, except: [ :destroy ] do
    post :report
  end
  get "tags/:tag_name" => "tags#show", as: :tag
  resources :tags, only: [ :index ]
  resources :shouts, only: [ :create ]
  resources :users, except: [ :destroy ] do
    get "shoutbox" => "shouts#index", as: :shouts
    get "shout-trail/:other_user_id" => "shouts#shouttrail", as: :shouttrail
    resources :posts, only: [ :index ]
    resources :replies, only: [ :index ]
  end

end
