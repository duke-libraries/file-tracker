class TrackFileJob < ApplicationJob

  queue_as :track_file

  def perform(path)
    TrackedFile.track!(path)
  end

end
