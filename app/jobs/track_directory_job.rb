class TrackDirectoryJob < ApplicationJob

  self.queue = :inventory

  def self.perform(tracked_directory_id)
    dir = TrackedDirectory.find(tracked_directory_id)
    dir.track!
  end

end
