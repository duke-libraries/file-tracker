class BatchFixityCheckJob < BatchJob

  def perform(max = nil)
    BatchFixityCheck.call(max)
  end

end
