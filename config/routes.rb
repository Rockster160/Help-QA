Rails.application.routes.draw do
  root to: 'index#index'

  get :flash_message, controller: "application"

  devise_for :users, path: "account", path_names: { sign_in: "login", sign_out: "logout" }

  get "tags/:tag_name" => "tags#show", as: :tag
  resources :tags, only: [ :index ]


  get "history((((/:claimed_status)/:reply_count)/:user_status)/:page)" => "posts#history"

  resources :posts, except: [ :destroy ] do
    post :report
    resources :replies, only: [ :create ]
  end

  resources :replies, only: [ :index ] do
  end

  resource :account, only: [ :index ] do
    resources :notices, only: [ :index ]
    resources :invites, only: [ :index ]
  end

  resources :users, except: [ :destroy ] do
    member do
      put :add_friend
      put :remove_friend
    end
    get "shoutbox" => "shouts#index", as: :shouts
    get "shout-trail/:other_user_id" => "shouts#shouttrail", as: :shouttrail
    resources :posts, only: [ :index ]
    resources :replies, only: [ :index ]
    resources :shouts, only: [ :create ]
  end

end
