Rails.application.routes.draw do
  resources :weights, only: [:index, :new, :create]
  resources :meals
  root to: 'dashboard#index'
  resources :workouts
  resources :diets
  resources :meal_diaries
  resources :fatsecret_foods, only: [:index, :show]
  devise_for :users
  resources :chats, only: [:index]
  resource :chat_responses, only: [:show]
  get 'unit_conversions/convert', to: 'unit_conversions#convert'
end
