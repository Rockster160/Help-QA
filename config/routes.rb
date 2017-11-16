Rails.application.routes.draw do
  root to: 'index#index'

  get :flash_message, controller: :application
  get :"terms-of-service", controller: :static_pages
  get :"privacy-policy", controller: :static_pages
  get :faq, controller: :static_pages
  get :donate, controller: :static_pages
  post :donate, controller: :static_pages, action: :one_time_donation
  get :emoji, controller: :static_pages
  get :chat, controller: :chat
  get "chat/remove_message/:id" => "chat#remove_message", as: :remove_message

  resource :feedback, path: "feedback", only: [:show, :create] do
    get ":id/edit", action: :edit, as: :edit
    post ":id/complete", action: :complete, as: :complete
    get :all, action: :index
    post :all, action: :redirect_all
  end

  devise_for :users, path: :account, path_names: { sign_in: "login", sign_out: "logout" }, controllers: {
    confirmations: "devise/user/confirmations",
    # omniauth_callbacks: "devise/user/omniauth_callbacks",
    passwords: "devise/user/passwords",
    registrations: "devise/user/registrations",
    sessions: "devise/user/sessions",
    unlocks: "devise/user/unlocks"
  }

  get "tags/:tags" => "tags#show", as: :tag
  resources :tags, only: [ :index ] do
    post :redirect, on: :collection
  end

  post "history" => "posts#history_redirect", as: :history_redirect
  get "history(((((/:claimed_status)/:reply_count)/:user_status)/:tags)/:page)" => "posts#history", as: :history

  get "url" => "replies#meta", as: :get_meta
  resources :posts, except: [ :destroy ] do
    member do
      get :vote
      get :subscribe
      post :mod
    end
    resources :replies, only: [ :create ] do
      post :mod
      get :favorite
      get :unfavorite
    end
  end

  resources :replies, only: [ :index ] do
  end

  resource :mod, only: [] do
    member do
      get :queue
    end
  end

  resource :account, only: [ :index, :edit, :update ] do
    get :confirm
    patch :confirm, action: :set_confirmation
    get :avatar
    post :avatar, action: :update_avatar
    get :notifications

    resources :subscriptions, only: [ :index, :destroy ]
    resources :friends, only: [ :index, :update, :destroy ]
    resources :profile, only: [ :index ] do
      post :update, on: :collection
    end
    resources :settings, only: [ :index ] do
      post :update, on: :collection
    end
    resources :notices, only: [ :index ]
    resources :invites, only: [ :index ]
  end

  post "update_user_search" => "users#update_user_search", as: :update_user_search
  resources :users, except: [ :destroy ] do
    member do
      put :add_friend
      put :remove_friend
      post :moderate
    end
    get "shoutbox" => "shouts#index", as: :shouts
    post "shoutbox" => "shouts#create"
    get "shout-trail/:other_user_id" => "shouts#shouttrail", as: :shouttrail
    resources :posts, only: [ :index ]
    resources :replies, only: [ :index ]
  end
  delete "shout/:id" => "shouts#destroy", as: :shout

  require 'sidekiq/web'
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  mount ActionCable.server => '/cable'

end
