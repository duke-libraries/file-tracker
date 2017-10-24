module TrackedFileAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      object_label_method { :path }

      list do
        scopes [nil, :ok, :not_ok, :modified, :missing, :error]
        field :id
        field :created_at do
          date_format :short
        end
        field :status, :status do
          pretty_status
        end
        field :size, :byte_size do
          pretty_size
        end
        field :path
      end

      show do
        field :id
        field :path
        field :created_at do
          date_format :long
        end
        field :updated_at do
          date_format :long
        end
        field :status, :status do
          pretty_status
        end
        field :fixity_checked_at do
          date_format :long
        end
        field :duracloud_status do
          pretty_value { I18n.t("duracloud_check.status.#{value}") }
        end
        field :duracloud_checked_at do
          date_format :long
        end
        field :md5
        field :sha1
        field :size, :byte_size do
          pretty_size
        end
        field :tracked_changes
        field :fixity_checks
      end
    end
  end

end
