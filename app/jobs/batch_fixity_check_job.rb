class BatchFixityCheckJob < ApplicationJob

  queue_as :batch_fixity

  def perform(max = nil)
    BatchFixityCheck.call(max)
  end

end
