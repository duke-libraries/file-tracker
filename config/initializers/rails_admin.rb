RailsAdmin.config do |config|

  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    # new
    export
    # bulk_delete
    show
    # edit
    # delete
    show_in_app
  end

  config.main_app_name = "DUL FileTracker v#{FileTracker::VERSION}"

  config.navigation_static_links = {
    'Queues' => '/queues',
  }

  # Include empty fields on show views
  config.compact_show_view = false
end

#
# Custom fields
#
module RailsAdmin::Config::Fields::Types

  class ByteSize < Integer
    register_instance_option :pretty_size do
      pretty_value { ActiveSupport::NumberHelper.number_to_human_size(value) }
    end
  end
  register(:byte_size, ByteSize)

  class Status < Integer
    register_instance_option :pretty_status do
      pretty_value { I18n.t("file_tracker.status.#{value}") }
    end
  end
  register(:status, Status)

end
