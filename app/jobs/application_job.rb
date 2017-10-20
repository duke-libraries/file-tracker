class ApplicationJob

  class_attribute :queue

  # retry_on Errno::EAGAIN, wait: 5.minutes # resource temporarily unavailable
  # retry_on Errno::EBADF                   # bad file descriptor
  # retry_on Errno::EIO, wait: 5.minutes    # I/O error

  # def large_file?(path)
  #   File.size(path) > FileTracker.large_file_threshhold
  # rescue Errno::ENOENT => e
  #   false
  # end

  # def self.perform_later(*args)
  #   Resque.enqueue(self, *args)
  # end

  # See Resque README re: MySQL and Rails 4.x
  # (Rails 5 not mentioned as of 2017-10-20).
  def self.before_perform_00_clear_active_connections(*args)
    ActiveRecord::Base.clear_active_connections!
  end

end
