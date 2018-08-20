class TrackDirectoryJob < ApplicationJob

  self.queue = :directory

  def self.perform(path)
    Dir.foreach(path) do |entry|
      next if ['.', '..'].include?(entry)
      abspath = File.join(path, entry)
      begin
        if FileTest.symlink?(abspath)
          next
        elsif FileTest.directory?(abspath)
          enqueue_path(abspath)
        elsif FileTest.file?(abspath)
          TrackFileJob.enqueue(abspath)
        end
      rescue *(FileTracker.log_file_errors) => e
        Rails.logger.error(e)
      end
    end
  rescue *(FileTracker.log_file_errors) => e
    Rails.logger.error(e)
  end

  def self.enqueue_directory(tracked_directory)
    if enqueue_path(tracked_directory.path)
      tracked_directory.update!(tracked_at: DateTime.now)
    end
  end

  def self.enqueue_path(path)
    Resque.enqueue(self, path)
  end

end
