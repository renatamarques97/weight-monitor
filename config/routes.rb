# frozen_string_literal: true

Rails.application.routes.draw do
  resources :weights, only: %i[index new create]
  resources :meals
  root to: 'dashboard#index'
  resources :workouts
  resources :diets
  resources :meal_diaries
  resources :fatsecret_foods, only: %i[index show]
  devise_for :users
  resources :chats, only: [:index]
  resource :chat_responses, only: [:show]

  get '/strava/connect', to: 'strava#connect', as: :strava_connect
  get '/strava/callback', to: 'strava#callback', as: :strava_callback
  post '/strava/sync', to: 'strava#sync', as: :strava_sync
  get '/strava/status', to: 'strava#status', as: :strava_status
  delete '/strava/disconnect', to: 'strava#disconnect', as: :strava_disconnect

  match '*path', to: 'errors#not_found', via: :all
end
