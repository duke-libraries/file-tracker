class TrackDirectoryJob < ApplicationJob

  queue_as :directory

  def perform(dir)
    files = []
    Find.find(dir) do |path|
      if File.directory?(path) && path != dir
        TrackDirectoryJob.perform_later(path)
        Find.prune
      elsif File.file?(path)
        # TrackedFile.track!(path)
        files << path
      end
    end
    TrackedFile.track!(*files)
  end

end
