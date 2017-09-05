class TrackDirectoryJob < ActiveJob::Base

  queue_as :track

  def perform(path)
    TrackedDirectory.track!(path)
  end

end
