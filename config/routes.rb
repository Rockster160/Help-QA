Rails.application.routes.draw do
  root to: 'index#index'

  get :flash_message, controller: :application
  get :"terms-of-service", controller: :static_pages
  get :"privacy-policy", controller: :static_pages
  get :faq, controller: :static_pages

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

  resources :posts, except: [ :destroy ] do
    get :vote
    resources :replies, only: [ :create ] do
      get :favorite
      get :unfavorite
    end
  end

  resources :replies, only: [ :index ] do
  end

  resource :account, only: [ :index, :edit, :update ] do
    get :confirm
    patch :confirm, action: :set_confirmation
    get :avatar
    post :avatar, action: :update

    resources :subscriptions, only: [ :index ]
    resources :friends, only: [ :index ]
    resources :settings, only: [ :index ]
    resources :notices, only: [ :index ]
    resources :invites, only: [ :index ]
  end

  resources :users, except: [ :destroy ] do
    member do
      put :add_friend
      put :remove_friend
    end
    get "shoutbox" => "shouts#index", as: :shouts
    post "shoutbox" => "shouts#create"
    get "shout-trail/:other_user_id" => "shouts#shouttrail", as: :shouttrail
    resources :posts, only: [ :index ]
    resources :replies, only: [ :index ]
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

end
