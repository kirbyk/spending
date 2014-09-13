Rails.application.routes.draw do
  resources :tags

  devise_for :users
  root to: 'home#index'
  get '/bank_login', to: 'home#bank_login'
  get '/transactions', to: 'home#transactions'
  post '/bank_create', to: 'home#bank_create'
end
