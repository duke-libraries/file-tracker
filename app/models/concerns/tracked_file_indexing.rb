module TrackedFileIndexing
  extend ActiveSupport::Concern

  included do
    include Indexing
  end

  def as_indexed_json(options = {})
    as_json(options.merge(except: [:id],
                          methods: [:absolute_path, :status_label, :folders, :base_folder]
                         )
           )
  end

end
