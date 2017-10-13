require "resque_web"

Rails.application.routes.draw do

  # Devise
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  # Rails admin
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # Resque web
  mount ResqueWeb::Engine => "/queues"

  root to: "rails_admin/main#dashboard"

end
