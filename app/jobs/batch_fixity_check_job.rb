class BatchFixityCheckJob < BatchJob

  before_perform :dequeue_fixity_jobs

  def perform(max = nil)
    BatchFixityCheck.call(max)
  end

  private

  def dequeue_fixity_jobs(*args)
    Resque::Job.destroy(:fixity, ActiveJob::QueueAdapters::ResqueAdapter::JobWrapper)
    Resque::Job.destroy(:fixity_large, ActiveJob::QueueAdapters::ResqueAdapter::JobWrapper)
  end

end
