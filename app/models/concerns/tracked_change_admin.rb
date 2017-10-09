module TrackedChangeAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        scopes [nil, :modification, :deletion, :pending, :accepted, :rejected]
        field :tracked_file
        field :change_type do
          pretty_value { I18n.t("file_tracker.change.type.#{value}") }
        end
        field :discovered_at do
          date_format :short
        end
        field :change_status do
          pretty_value { I18n.t("file_tracker.change.status.#{value}") }
        end
      end

      show do
        field :id
        field :tracked_file
        field :change_type do
          pretty_value { I18n.t("file_tracker.change.type.#{value}") }
        end
        field :discovered_at do
          date_format :long
        end
        field :change_status do
          pretty_value { I18n.t("file_tracker.change.status.#{value}") }
        end
        field :sha1
        field :size, :byte_size do
          pretty_size
        end
        field :created_at do
          date_format :long
        end
      end
    end
  end

end
