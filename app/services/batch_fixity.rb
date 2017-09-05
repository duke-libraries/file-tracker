class BatchFixity

  class_attribute :check_period
  self.check_period = 60

  class_attribute :check_limit
  self.check_limit = 10**5

  def self.call
    count = queue(not_checked)
    limit = check_limit - count
    count += queue(check_due(limit))
  end

  def self.queue(tracked_files)
    queued = tracked_files.each do |tracked_file|
      FixityCheckJob.perform_later(tracked_file)
    end
    queued.size
  end

  def self.not_checked(limit = nil)
    TrackedFile
      .where(fixity_checked_at: nil)
      .order(created_at: :asc)
      .limit(limit || check_limit)
  end

  def self.check_due(limit = nil)
    TrackedFile
      .where("fixity_checked_at < ?", cutoff_date)
      .order(fixity_checked_at: :asc)
      .limit(limit || check_limit)
  end

  def self.cutoff_date
    DateTime.now - check_period.days
  end

end
