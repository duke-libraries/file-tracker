module UserAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      object_label_method { :uid }

      list do
        scopes [nil, :admins]
        field :id
        field :uid
        field :is_admin
        field :created_at do
          date_format :short
        end
      end

      show do
        field :id
        field :uid
        field :email
        field :is_admin
        field :created_at do
          date_format :long
        end
        field :updated_at do
          date_format :long
        end
      end

      edit do
        field :is_admin
      end
    end
  end

end
