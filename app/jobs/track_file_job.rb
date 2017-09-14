class TrackFileJob < ApplicationJob

  GIGABYTE = 10**9

  queue_as do
    path = self.arguments.first
    File.size(path) > GIGABYTE ? :large_file : :file
  end

  def perform(path)
    TrackedFile.track!(path)
  end

end
