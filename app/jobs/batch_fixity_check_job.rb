class BatchFixityCheckJob < ApplicationJob

  self.queue = :batch

  def self.perform(max = nil)
    BatchFixityCheck.call(max)
  end

end
