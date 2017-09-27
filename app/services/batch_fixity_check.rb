class BatchFixityCheck

  attr_accessor :max

  def self.call(max = nil)
    new(max).call
  end

  def initialize(max = nil)
    @max = max ? max.to_i : FileTracker.batch_fixity_check_limit
  end

  def call
    count = queue(not_checked.limit(max))
    if count < max
      count += queue(check_due.limit(max - count))
    end
    count
  end

  def not_checked
    TrackedFile.fixity_not_checked.order(created_at: :asc)
  end

  def check_due
    TrackedFile.fixity_check_due.order(fixity_checked_at: :asc)
  end

  def queue(tracked_files)
    queued = tracked_files.each do |tracked_file|
      CheckFixityJob.perform_later(tracked_file)
    end
    queued.size
  end

end
