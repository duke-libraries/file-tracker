require 'find'

class TrackDirectoryJob < ApplicationJob

  self.queue = :inventory

  def self.perform(dir)
    files = []
    Find.find(dir) do |path|
      if File.directory?(path) && path != dir
        Resque.enqueue(self, path)
        Find.prune
      elsif File.file?(path)
        files << path
      end
    end
    TrackedFile.track!(*files)
  end

end
