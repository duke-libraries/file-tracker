class DuracloudDeleteJob < DuracloudJob

  def self.perform(space_id, content_id)
    Duracloud::Content.delete(space_id: space_id, content_id: content_id)
  end

end
