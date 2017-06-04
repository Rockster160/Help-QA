Rails.application.routes.draw do
  root to: 'index#index'

  get :flash_message, controller: "application"

  devise_for :users, path: "account"
end
