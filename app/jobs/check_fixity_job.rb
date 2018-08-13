class CheckFixityJob < ApplicationJob
  include LargeFileJob

  self.queue = :fixity
  self.large_file_queue = :fixity_large

  def self.perform(tracked_file_id)
    tracked_file = TrackedFile.find(tracked_file_id)
    tracked_file.check_fixity!
  end

  def self.enqueue(tracked_file)
    Resque.enqueue_to(queue_for_tracked_file(tracked_file), self, tracked_file.id)
  end

end
