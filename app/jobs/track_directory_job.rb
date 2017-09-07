class TrackDirectoryJob < ApplicationJob

  queue_as :track

  def perform(tracked_directory)
    tracked_directory.track!
  end

end
