module TrackedDirectoryAdmin
  extend ActiveSupport::Concern

  included do

    rails_admin do

      object_label_method { :path }

      list do
        field :id do
          label { "ID" }
        end
        field :path
        field :count do
          label { "File Count" }
        end
        field :created_at do
          label { "Added" }
        end
        field :tracked_at do
          label { "Inventoried" }
        end
      end

      show do
        field :id do
          label { "ID" }
        end
        field :path
        field :count do
          label { "File Count" }
        end
        field :created_at do
          label { "Added" }
        end
        field :tracked_at do
          label { "Inventoried" }
        end
      end

    end # rails_admin

  end

end
