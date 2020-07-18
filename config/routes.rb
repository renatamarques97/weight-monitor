Rails.application.routes.draw do
  resources :weights, only: [:new, :create]
  resources :meals
  root to: 'dashboard#index'
  resources :diets
  devise_for :users
end
