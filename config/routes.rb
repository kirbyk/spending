Rails.application.routes.draw do
  resources :tags

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root to: 'home#splash'
  get '/dashboard', to: 'home#dashboard'
  get '/transactions', to: 'home#transactions'
  post '/bank_create', to: 'home#bank_create'
  post '/plaidComplete', to: 'home#plaid_hook'
end
