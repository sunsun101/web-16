# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  get 'site/index'
  resources :projects
  root to: 'site#index'
end
