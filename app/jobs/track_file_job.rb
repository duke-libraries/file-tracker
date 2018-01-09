class TrackFileJob < ApplicationJob

  self.queue = :file

  def self.perform(path)
    TrackedFile.track!(path)
  end

end
