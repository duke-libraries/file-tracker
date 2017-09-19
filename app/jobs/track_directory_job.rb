require 'find'

class TrackDirectoryJob < ApplicationJob

  queue_as :directory

  def perform(dir)
    Find.find(dir) do |path|
      next if !File.directory?(path) || Dir.empty?(path)
      TrackFilesJob.perform_later(path)
    end
  end

end
