require 'find'

class ApplicationJob < ActiveJob::Base

  retry_on Errno::EAGAIN, wait: 5.minutes # resource temporarily unavailable
  retry_on Errno::EBADF                   # bad file descriptor
  retry_on Errno::EIO, wait: 5.minutes    # I/O error

  def large_file?(path)
    File.size(path) > FileTracker.large_file_threshhold
  rescue Errno::ENOENT => e
    false
  end

  before_perform do |job|
    ActiveRecord::Base.clear_active_connections!
  end

end
