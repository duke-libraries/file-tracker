class BatchFixityCheck

  attr_accessor :max

  def self.call(max = nil)
    new(max).call
  end

  def initialize(max = nil)
    @max = max ? max.to_i : FileTracker.batch_fixity_check_limit
  end

  def call
    tracked_files = TrackedFile.check_fixity?.order(fixity_checked_at: :asc, created_at: :asc)
    queue(tracked_files)
  end

  def queue(tracked_files)
    queued = tracked_files.each do |tracked_file|
      CheckFixityJob.perform_later(tracked_file)
    end
    queued.size
  end

end
