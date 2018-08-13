require 'find'

class TrackDirectoryJob < ApplicationJob

  self.queue = :directory

  def self.perform(path)
    Find.find(path) do |subpath|
      if FileTest.symlink?(subpath) || path == subpath
        next
      elsif FileTest.directory?(subpath)
        enqueue_path(subpath)
        Find.prune
      elsif FileTest.file?(subpath)
        TrackFileJob.enqueue(subpath)
      end
    end
  end

  def self.enqueue_directory(tracked_directory)
    enqueue_path(tracked_directory.path)
  end

  def self.enqueue_path(path)
    Resque.enqueue(self, path)
  end

end
