require "resque_web"

Rails.application.routes.draw do

  # Rails admin
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # Resque web
  mount ResqueWeb::Engine => "/queues"

end
