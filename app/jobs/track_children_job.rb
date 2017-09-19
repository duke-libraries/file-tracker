class TrackChildrenJob < ApplicationJob

  queue_as :children

  def perform(path)
    children = Dir.entries(path) - ['.', '..']

    children.each do |child|
      abspath = File.absolute_path(child, path)
      if File.directory?(abspath) && !Dir.empty?(abspath)
        TrackChildrenJob.perform_later(abspath)
      end
    end

    HashdeepJob.perform_later(path)
  end

end
