class TrackFileJob < ApplicationJob

  self.queue = :inventory

  def self.perform(path)
    TrackedFile.track!(path)
  end

end
