module TrackedFileAdmin
  extend ActiveSupport::Concern
  extend CommonAdmin

  included do
    rails_admin do
      object_label_method { :path }

      list do
        field :path
        field :created_at do
          short_date_format
        end
        field :fixity_status do
          pretty_status
        end
      end

      show do
        field :id
        field :path
        field :created_at do
          long_date_format
        end
        field :fixity_status do
          pretty_status
        end
        field :fixity_checked_at do
          long_date_format
        end
        field :md5
        field :sha1
        field :size do
          pretty_size
        end
      end
    end
  end

end
