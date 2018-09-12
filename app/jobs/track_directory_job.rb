class TrackDirectoryJob < ApplicationJob

  queue_as :directory

  FileTracker.log_file_errors.each do |exception|
    discard_on(exception) do |job, e|
      logger.error(e)
    end
  end

  def perform(path)
    Dir.foreach(path) do |entry|
      next if ['.', '..'].include?(entry)
      abspath = File.join(path, entry)
      begin
        if FileTest.symlink?(abspath)
          next
        elsif FileTest.directory?(abspath)
          TrackDirectoryJob.perform_later(abspath)
        elsif FileTest.file?(abspath)
          TrackFileJob.perform_later(abspath)
        end
      rescue *(FileTracker.log_file_errors) => e
        logger.error(e)
      end
    end
  end

end
