module FixityCheckResultAdmin
  extend ActiveSupport::Concern
  include CommonAdmin

  included do
    rails_admin do
      list do
        field :path
        field :display_status
        field :started_at do
          label { "Checked At" }
          strftime_format SHORT_DATE_FORMAT
        end
      end

      show do
        field :id
        field :path
        field :display_status
        field :started_at do
          strftime_format LONG_DATE_FORMAT
        end
        field :finished_at do
          strftime_format LONG_DATE_FORMAT
        end
        field :md5
        field :sha1
        field :display_size
        field :message
      end
    end
  end

end
