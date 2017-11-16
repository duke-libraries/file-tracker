RailsAdmin.config do |config|

  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  config.authorize_with :cancan

  config.included_models = %w( TrackedDirectory TrackedFile TrackedChange FixityCheck User )

  config.actions do
    dashboard # mandatory
    index     # mandatory
    new do
      only %w( TrackedDirectory )
    end
    export
    bulk_delete
    show
    edit do
      only %w( TrackedDirectory User )
    end
    delete
    show_in_app
  end

  config.main_app_name = "DUL FileTracker v#{FileTracker::VERSION}"

  config.navigation_static_links = {
    'Queues' => '/queues',
  }

  # Include empty fields on show views
  config.compact_show_view = false
end
