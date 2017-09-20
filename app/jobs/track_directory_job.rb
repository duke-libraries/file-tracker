class TrackDirectoryJob < ApplicationJob

  queue_as :directory

  def perform(dir)
    Find.find(dir) do |path|
      next if path == dir
      if File.directory?(path)
        TrackDirectoryJob.perform_later(path)
        Find.prune
      elsif File.file?(path)
        TrackedFile.find_or_create_by!(path: path)
      end
    end
  end

end
