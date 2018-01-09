module TrackedDirectoryAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      object_label_method { :path }

      list do
        field :id
        field :title
        field :path
        field :created_at do
          date_format :short
        end
        field :tracked_at do
          date_format :short
        end
      end

      show do
        field :id
        field :title
        field :path
        field :count
        field :size do
          pretty_value { ActiveSupport::NumberHelper.number_to_human_size(value) }
        end
        field :created_at do
          date_format :long
        end
        field :updated_at do
          date_format :long
        end
        field :tracked_at do
          date_format :long
        end
      end

      edit do
        field :path do
          read_only { bindings[:object].persisted? }
        end
        field :title
      end
    end
  end

end
