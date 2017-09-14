class TrackChildrenJob < ApplicationJob

  queue_as :children

  def perform(path)
    children = Dir.entries(path) - ['.', '..']
    children.each do |child|
      abspath = File.absolute_path(child, path)
      if File.file?(abspath)
        TrackFileJob.perform_later(abspath) unless TrackedFile.exists?(path: abspath)
      elsif File.directory?(abspath)
        TrackChildrenJob.perform_later(abspath) unless Dir.empty?(abspath)
      end
    end
  end

end
