module TrackedChangeAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        field :path
        field :change_type
        field :discovered_at do
          date_format :short
        end
        field :change_status
      end

      show do
        field :id
        field :path
        field :change_type
        field :discovered_at do
          date_format :long
        end
        field :change_status
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
