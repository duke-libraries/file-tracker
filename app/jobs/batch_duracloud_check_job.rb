class BatchDuracloudCheckJob < BatchJob

  def self.perform(status = nil)
    status ? check_by_status(status) : check_all
  end

  def self.check_all
    TrackedDirectory.where.not(duracloud_space: nil).each do |tracked_dir|
      tracked_dir.check_duracloud!
    end
  end

  def self.check_by_status(status)
    TrackedFile.ok.where(duracloud_status: status.to_i).each do |tracked_file|
      Resque.enqueue(DuracloudCheckJob, tracked_file.id)
    end
  end

end
