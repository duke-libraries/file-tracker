class DuracloudCheckJob < DuracloudJob

  self.queue = :duracloud

  def self.perform(tracked_file_id)
    tracked_file = TrackedFile.find(tracked_file_id)
    if tracked_file.duracloud_checkable?
      tracked_file.check_duracloud!
    end
  end

end
