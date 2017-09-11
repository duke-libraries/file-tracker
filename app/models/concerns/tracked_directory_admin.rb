module TrackedDirectoryAdmin
  extend ActiveSupport::Concern

  included do

    rails_admin do

      object_label_method { :path }

      list do
        field :id
        field :path
        field :count
        field :display_size
        field :created_at
        field :tracked_at
      end

      show do
        field :id
        field :path
        field :count
        field :display_size
        field :created_at
        field :tracked_at
      end

    end # rails_admin

  end

end
