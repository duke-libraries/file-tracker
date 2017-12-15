module TrackedChangeAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        scopes [:pending, :modification, :deletion, :accepted, :rejected, nil]
        field :id
        field :discovered_at do
          date_format :short
        end
        field :change_type do
          pretty_value { I18n.t("file_tracker.change.type.#{value}") }
        end
        field :change_status do
          pretty_value { I18n.t("file_tracker.change.status.#{value}") }
        end
        field :tracked_file
      end

      show do
        field :id
        field :tracked_file
        field :discovered_at do
          date_format :long
        end
        field :change_type do
          pretty_value { I18n.t("file_tracker.change.type.#{value}") }
        end
        field :change_status do
          pretty_value { I18n.t("file_tracker.change.status.#{value}") }
        end
        field :message
        field :sha1
        field :size do
          pretty_value { "%s (%s)" % [value, ActiveSupport::NumberHelper.number_to_human_size(value)] }
        end
        field :created_at do
          date_format :long
        end
        field :updated_at do
          date_format :long
        end
      end
    end
  end

end
