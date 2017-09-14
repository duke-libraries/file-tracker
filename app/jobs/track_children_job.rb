class TrackChildrenJob < ApplicationJob

  queue_as :children

  def perform(path)
    children = Dir.entries(path) - ['.', '..']
    files = []

    children.each do |child|
      abspath = File.absolute_path(child, path)
      if File.file?(abspath)
        files << abspath
      elsif File.directory?(abspath)
        TrackChildrenJob.perform_later(abspath) unless Dir.empty?(abspath)
      end
    end

    if files.present?
      tracked_files = TrackedFile.under(path).pluck(:path)
      (files - tracked_files).each do |file|
        TrackFileJob.perform_later(file)
      end
    end
  end

end
