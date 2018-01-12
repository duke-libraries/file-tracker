class BatchFixityCheck

  attr_accessor :max

  def self.call(max = nil)
    new(max).call
  end

  def initialize(max = nil)
    @max = max ? max.to_i : FileTracker.batch_fixity_check_limit
  end

  def call
    queued = tracked_files.each do |tracked_file|
      queue = CheckFixityJob.queue_for_tracked_file(tracked_file)
      Resque.enqueue_to(queue, CheckFixityJob, tracked_file.id)
    end
    queued.size
  end

  def tracked_files
    TrackedFile
      .where("fixity_checked_at IS NULL OR update_at < ? OR fixity_checked_at < ?",
             check_last_seen_date, fixity_check_cutoff_date)
      .order(fixity_checked_at: :asc, created_at: :asc)
      .limit(max)
   end

  def fixity_check_cutoff_date
    DateTime.now - FileTracker.fixity_check_period.days
  end

  def check_last_seen_date
    DateTime.now - FileTracker.check_last_seen_period.days
  end

end
