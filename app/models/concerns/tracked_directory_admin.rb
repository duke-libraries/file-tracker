module TrackedDirectoryAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      object_label_method { :path }

      list do
        field :id
        field :title
        field :path
        # field :count
        # field :size, :byte_size do
        #   pretty_size
        # end
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
        field :size, :byte_size do
          pretty_size
        end
        field :created_at do
          date_format :long
        end
        field :tracked_at do
          date_format :long
        end
      end
    end
  end

end
