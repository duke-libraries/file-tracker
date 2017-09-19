require 'find'

class TrackChildrenJob < ApplicationJob

  queue_as :children

  def perform(dir)
    Find.find(dir) do |path|
      if File.directory?(path)
        TrackChildrenJob.perform_later(path)
        Find.prune
      elsif File.file?(path)
        TrackedFile.track!(path)
      end
    end
  end

end
