# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  get 'site/index'
  get 'site/admin_dashboard', as: :admin_dashboard
  resources :projects do
    resources :students
  end
  root to: 'site#index'
end
