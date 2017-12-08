module TrackedFileIndexing
  extend ActiveSupport::Concern

  included do
    include Indexing
  end

  def as_indexed_json(options = {})
    super.merge(
      "status_label"=>status_label,
      "folders"=>pathname.dirname.descend.map(&:to_s)
    )
  end

end
