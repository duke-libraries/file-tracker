class TrackDirectoryJob < ApplicationJob

  queue_as :directory

  FileTracker.log_file_errors.each do |exception|
    discard_on(exception) do |job, e|
      logger.error(e)
    end
  end

end
