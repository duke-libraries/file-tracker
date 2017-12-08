module TrackedFileIndexing
  extend ActiveSupport::Concern

  included do
    include Indexing
  end

  def as_indexed_json(options = {})
    as_json(
      options.merge(
             methods: [:absolute_path, :status_label, :folders],
             include: {
               tracked_directory: {
                 only: [:path, :title]
               }
             }
    )
    )
  end

end
