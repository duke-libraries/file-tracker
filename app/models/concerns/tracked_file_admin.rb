module TrackedFileAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      object_label_method { :path }

      list do
        field :id
        field :created_at do
          date_format :short
        end
        field :size do
          pretty_value { ActiveSupport::NumberHelper.number_to_human_size(value) }
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
        field :fixity_checked_at do
          date_format :long
        end
        field :sha1
        field :size do
          pretty_value { ActiveSupport::NumberHelper.number_to_human_size(value) }
        end
      end
    end
  end

end
