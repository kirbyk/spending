Rails.application.routes.draw do
  resources :tags

  devise_for :users
  root to: 'home#index'
end
