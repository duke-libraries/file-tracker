module FixityCheckResultAdmin
  extend ActiveSupport::Concern
  extend CommonAdmin

  included do
    rails_admin do
      object_label_method { :path }

      list do
        field :path
        field :status do
          pretty_status
        end
        field :started_at do
          label { "Checked At" }
          short_date_format
        end
      end

      show do
        field :id
        field :path
        field :status do
          pretty_status
        end
        field :started_at do
          long_date_format
        end
        field :finished_at do
          long_date_format
        end
        field :md5
        field :sha1
        field :size do
          pretty_size
        end
        field :message
      end
    end
  end

end
