module TrackedDirectoryAdmin
  extend ActiveSupport::Concern
  extend CommonAdmin

  included do
    rails_admin do
      object_label_method { :path }

      list do
        field :id
        field :path
        field :count
        field :size do
          pretty_size
        end
        field :created_at do
          short_date_format
        end
        field :tracked_at do
          short_date_format
        end
      end

      show do
        field :id
        field :path
        field :count
        field :size do
          pretty_size
        end
        field :created_at do
          long_date_format
        end
        field :tracked_at do
          long_date_format
        end
      end
    end
  end

end
