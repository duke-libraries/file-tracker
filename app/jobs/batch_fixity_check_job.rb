class BatchFixityCheckJob < BatchJob

  def self.perform(max = nil)
    BatchFixityCheck.call(max)
  end

end
