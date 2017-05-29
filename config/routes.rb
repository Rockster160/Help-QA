Rails.application.routes.draw do
  root to: 'index#index'
  
  get :flash_message, controller: "application"
end
