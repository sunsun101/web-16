# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  get "site/index"
  get "site/admin_dashboard", as: :admin_dashboard
  resources :projects
  resources :students
  post "projects/:id/students", as: :add_student_to_project, controller: :projects, action: :add_student
  root to: "site#index"
  patch "site/users"
  delete "users/destroy", to: "site#destroy"
  get "site/users", to: "site#get_users"
end
