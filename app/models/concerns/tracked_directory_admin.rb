module TrackedDirectoryAdmin
  extend ActiveSupport::Concern
  include CommonAdmin

  included do
    rails_admin do
      object_label_method { :path }

      list do
        field :id
        field :path
        field :count
        field :display_size
        field :created_at do
          strftime_format SHORT_DATE_FORMAT
        end
        field :tracked_at do
          strftime_format SHORT_DATE_FORMAT
        end
      end

      show do
        field :id
        field :path
        field :count
        field :display_size
        field :created_at do
          strftime_format LONG_DATE_FORMAT
        end
        field :tracked_at do
          strftime_format LONG_DATE_FORMAT
        end
      end
    end
  end

end
