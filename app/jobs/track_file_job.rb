class TrackFileJob < ApplicationJob
  include LargeFileJob

  self.queue = :file
  self.large_file_queue = :file_large

  def self.perform(path)
    TrackedFile.track!(path)
  end

  def self.enqueue_file(tracked_file)
    Resque.enqueue_to(queue_for_tracked_file(tracked_file), self, tracked_file.path)
  end

  def self.enqueue(path)
    Resque.enqueue_to(queue_for_path(path), self, path)
  rescue *(FileTracker.log_file_errors) => e
    Rails.logger.error(e)
  end

  def self.queue_for_path(path)
    large_file?(path) ? large_file_queue : queue
  end

  def self.large_file?(path)
    File.size(path) >= FileTracker.large_file_threshhold
  end

end
