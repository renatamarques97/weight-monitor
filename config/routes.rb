# frozen_string_literal: true

Rails.application.routes.draw do
  resources :weights, only: [:new, :create]
  resources :meals
  root to: 'dashboard#index'
  resources :runnings, only: [:new, :create]
  resources :diets
  devise_for :users
  resources :chats, only: [:index]
  resource :chat_responses, only: [:show]
end
