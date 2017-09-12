Rails.application.routes.draw do
  root to: 'index#index'

  get :flash_message, controller: "application"

  devise_for :users, path: :account, path_names: { sign_in: "login", sign_out: "logout" }

  get "tags/:tags" => "tags#show", as: :tag
  resources :tags, only: [ :index ] do
    post :redirect, on: :collection
  end

  post "history" => "posts#history_redirect", as: :history_redirect
  get "history(((((/:claimed_status)/:reply_count)/:user_status)/:tags)/:page)" => "posts#history", as: :history

  resources :posts, except: [ :destroy ] do
    post :report
    resources :replies, only: [ :create ]
  end

  resources :replies, only: [ :index ] do
  end

  resource :account, only: [ :index, :edit, :update ] do
    get :confirm
    patch :confirm, action: :set_confirmation
    get :notices
    patch :notices, action: :set_notices
    get :subscriptions
    patch :subscriptions, action: :set_subscriptions
    get :invites
    patch :invites, action: :set_invites
    get :"my-tags"
    patch :"my-tags", action: :set_tags
    get :profile
    patch :profile, action: :set_profile
    get :friends
    patch :friends, action: :set_friends
    get :avatar
    patch :avatar, action: :set_avatar
    get :settings
    patch :settings, action: :set_settings
    get :map
    patch :map, action: :set_map

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
