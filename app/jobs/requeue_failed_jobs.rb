class RequeueFailedJobs

  def self.call
    jobs_to_requeue.each { |id, item| requeue(id, item) }
  end

  def self.jobs_to_requeue
    Resque::Failure.to_enum.select { |id, item| requeue?(item) }
  end

  def self.requeue?(item)
    FileTracker.retry_job_errors.include?(item["exception"])
  end

  def self.requeue(id, item)
    Resque::Failure.requeue(id)
    Rails.logger.warn("Failed job requeued: #{item.inspect}")
    Resque::Failure.remove(id)
  end

end
