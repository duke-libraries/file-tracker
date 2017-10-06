module TrackedFileAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      object_label_method { :path }

      list do
        scopes [nil, :ok, :not_ok, :modified, :missing, :error]
        field :path
        field :created_at do
          date_format :short
        end
        field :status, :status do
          pretty_status
        end
      end

      show do
        field :id
        field :path
        field :created_at do
          date_format :long
        end
        field :status, :status do
          pretty_status
        end
        field :fixity_checked_at do
          date_format :long
        end
        field :md5
        field :sha1
        field :size, :byte_size do
          pretty_size
        end
      end
    end
  end

end
