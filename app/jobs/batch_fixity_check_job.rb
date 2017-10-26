class BatchFixityCheckJob < BatchJob

  def self.before_perform_dequeue_fixity_jobs
    CheckFixityJob.dequeue_all
  end

  def self.perform(max = nil)
    BatchFixityCheck.call(max)
  end

end
