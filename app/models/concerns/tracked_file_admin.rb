module TrackedFileAdmin
  extend ActiveSupport::Concern

  included do

    rails_admin do

      object_label_method { :path }

      list do
        field :path
        field :created_at do
          label { "Added" }
        end
        field :display_fixity_status do
          label { "Fixity Status" }
        end
      end

      show do
        field :id do
          label { "ID" }
        end
        field :path
        field :created_at do
          label { "Added" }
        end
        field :display_fixity_status do
          label { "Fixity Status" }
        end
        field :fixity_checked_at do
          label { "Fixity Checked" }
        end
        field :md5 do
          label { "MD5" }
        end
        field :sha1 do
          label { "SHA1" }
        end
        field :display_size do
          label { "Size" }
        end
      end

    end # rails_admin

  end

end
