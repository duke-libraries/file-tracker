class BatchFixityCheckJob < ApplicationJob

  self.queue = :batch

  def perform(max = nil)
    BatchFixityCheck.call(max)
  end

end
