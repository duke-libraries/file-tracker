class BatchJob < ApplicationJob
  self.queue = :batch
end
