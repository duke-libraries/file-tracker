class BatchFixityCheck

  class_attribute :limit
  self.limit = ENV.fetch("BATCH_FIXITY_CHECK_LIMIT", 10**5).to_i

  def self.call(max = nil)
    new(max).call
  end

  def initialize(max = nil)
    self.limit = max.to_i if max
  end

  def call
    count = queue TrackedFile.fixity_not_checked.limit(limit)
    if count < limit
      count += queue TrackedFile.fixity_check_due.limit(limit - count)
    end
    count
  end

  def queue(tracked_files)
    queued = tracked_files.each do |tracked_file|
      CheckFixityJob.perform_later(tracked_file)
    end
    queued.size
  end

end
