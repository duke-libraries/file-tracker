class TrackFileJob < ApplicationJob

  class_attribute :large_file_threshhold
  self.large_file_threshhold = ENV.fetch("LARGE_FILE_THRESHHOLD", 10**9).to_i

  queue_as do
    path = self.arguments.first
    large_file?(path) ? :large_file : :file
  end

  def large_file?(path)
    File.size(path) > large_file_threshhold
  end

  def perform(path)
    TrackedFile.track!(path)
  end

end
