class TrackDirectoryJob < ApplicationJob

  queue_as :track_directory

  def perform(dir)
    if dir.is_a?(TrackedDirectory)
      dir.track!
    else
      TrackedDirectory.track!(dir)
    end
  end

end
