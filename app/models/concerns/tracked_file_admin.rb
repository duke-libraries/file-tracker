module TrackedFileAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      object_label_method { :to_s }

      list do
        scopes [ nil, :ok, :not_ok, :modified, :missing, :error ]
        field :id
        field :created_at do
          date_format :short
        end
        field :status do
          pretty_value { I18n.t("file_tracker.status.#{value}") }
        end
        field :size do
          pretty_value { ActiveSupport::NumberHelper.number_to_human_size(value) }
        end
        field :tracked_directory
        field :path
      end

      show do
        field :id
        field :tracked_directory
        field :path
        field :created_at do
          date_format :long
        end
        field :updated_at do
          date_format :long
        end
        field :status do
          pretty_value { I18n.t("file_tracker.status.#{value}") }
        end
        field :fixity_checked_at do
          date_format :long
        end
        field :sha1
        field :size do
          pretty_value { "%s (%s)" % [value, ActiveSupport::NumberHelper.number_to_human_size(value)] }
        end
        field :tracked_changes
        field :fixity_checks
      end
    end
  end

end
