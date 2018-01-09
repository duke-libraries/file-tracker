class TrackDirectoryJob < ApplicationJob

  self.queue = :directory

  def self.perform(tracked_directory_id)
    dir = TrackedDirectory.find(tracked_directory_id)
    dir.track!
  end

end
