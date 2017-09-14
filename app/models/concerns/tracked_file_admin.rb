module TrackedFileAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      object_label_method { :path }

      list do
        field :path
        field :created_at
        field :display_fixity_status
      end

      show do
        field :id
        field :path
        field :created_at
        field :display_fixity_status
        field :fixity_checked_at
        field :md5
        field :sha1
        field :display_size
      end
    end # rails_admin
  end

end
