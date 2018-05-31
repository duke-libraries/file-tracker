class TrackFileJob < ApplicationJob
  include LargeFileJob

  self.queue = :file
  self.large_file_queue = :file_large

  def self.perform(path)
    TrackedFile.track!(path)
  end

end
