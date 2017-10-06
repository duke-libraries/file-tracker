class FixityJob < ApplicationJob

  class_attribute :base_queue
  class_attribute :large_file_queue

  def self.queues
    [ base_queue, large_file_queue ]
  end

  def self.enqueued_count
    queues.map { |q| QueueManager.queue_size(q) }.reduce(:+)
  end

  queue_as do
    tracked_file.large? ? large_file_queue : base_queue
  end

  def tracked_file
    arguments.first
  end

end
