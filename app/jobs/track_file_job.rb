class TrackFileJob < ApplicationJob

  discard_on ActiveJob::DeserializationError

  queue_as { large_file? ? :file_large : :file }

  def perform(path)
    TrackedFile.track!(path)
  end

  def large_file?
    File.size(path) >= FileTracker.large_file_threshhold
  end

  def path
    arguments.first
  end

end
