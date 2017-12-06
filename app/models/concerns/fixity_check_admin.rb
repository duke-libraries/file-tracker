module FixityCheckAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        scopes [ nil, :ok, :not_ok, :modified, :missing, :error ]
        field :id
        field :started_at do
          label { "Checked At" }
          date_format :short
        end
        field :status do
          pretty_value { I18n.t("file_tracker.status.#{value}") }
        end
        field :tracked_file
      end

      show do
        field :id
        field :tracked_file
        field :started_at do
          date_format :long
        end
        field :finished_at do
          date_format :long
        end
        field :status do
          pretty_value { I18n.t("file_tracker.status.#{value}") }
        end
        field :sha1
        field :size do
          pretty_value { ActiveSupport::NumberHelper.number_to_human_size(value) }
        end
        field :message
      end
    end
  end

end
