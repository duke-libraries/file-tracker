module TrackedFileAdmin
  extend ActiveSupport::Concern
  include CommonAdmin

  included do
    rails_admin do
      object_label_method { :path }

      list do
        field :path
        field :created_at do
          strftime_format SHORT_DATE_FORMAT
        end
        field :display_fixity_status
      end

      show do
        field :id
        field :path
        field :created_at do
          strftime_format LONG_DATE_FORMAT
        end
        field :display_fixity_status
        field :fixity_checked_at do
          strftime_format LONG_DATE_FORMAT
        end
        field :md5
        field :sha1
        field :display_size
      end
    end
  end

end
