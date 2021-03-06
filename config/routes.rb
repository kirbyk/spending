Rails.application.routes.draw do
  resources :tags

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root to: 'home#splash'
  get '/dashboard', to: 'home#dashboard'
  get '/transactions', to: 'home#transactions'
  get 'mfa_new', to: 'home#mfa_new'
  post '/bank_create', to: 'home#bank_create'
  post '/mfa_save', to: 'home#mfa_save'
end
