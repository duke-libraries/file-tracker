module TrackedFileAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        # field :id
        field :path
        # field :md5
        # field :sha1
        # field :size
        field :fixity_checked_at
        field :fixity_status
        field :created_at
      end
    end
  end

end
