class FixityJob < ApplicationJob

  class_attribute :base_queue
  class_attribute :large_file_queue

  def self.queues
    [ base_queue, large_file_queue ]
  end

  def self.queued
    queues.map { |q| QueueManager.queue_size(q) }.reduce(:+)
  end

  queue_as do
    tracked_file = self.arguments.first
    if large_file?(tracked_file.path)
      large_file_queue
    else
      base_queue
    end
  end

end
