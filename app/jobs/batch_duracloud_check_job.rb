class BatchDuracloudCheckJob < BatchJob

  def self.perform
    TrackedDirectory.where.not(duracloud_space: nil).each do |tracked_dir|
      tracked_dir.check_duracloud!
    end
  end

end
