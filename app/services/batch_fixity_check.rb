class BatchFixityCheck

  class_attribute :check_limit
  self.check_limit = ENV.fetch("BATCH_FIXITY_CHECK_LIMIT", 10**5).to_i

  def self.call
    count = queue(not_checked)
    limit = check_limit - count
    count += queue(check_due(limit))
  end

  def self.queue(tracked_files)
    queued = tracked_files.each do |tracked_file|
      CheckFixityJob.perform_later(tracked_file)
    end
    queued.size
  end

  def self.not_checked(limit = nil)
    TrackedFile.fixity_not_checked.limit(limit || check_limit)
  end

  def self.check_due(limit = nil)
    TrackedFile.fixity_check_due.limit(limit || check_limit)
  end

end
