module FixityCheckAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      # object_label_method { :path }

      list do
        scopes [nil, :ok, :not_ok, :modified, :missing, :error]
        field :tracked_file
        field :status, :status do
          pretty_status
        end
        field :started_at do
          label { "Checked At" }
          date_format :short
        end
      end

      show do
        field :id
        field :tracked_file
        field :status, :status do
          pretty_status
        end
        field :started_at do
          date_format :long
        end
        field :finished_at do
          date_format :long
        end
        field :md5
        field :sha1
        field :size, :byte_size do
          pretty_size
        end
        field :message
      end
    end
  end

end
