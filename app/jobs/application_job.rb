require 'find'

class ApplicationJob < ActiveJob::Base

  # "Resource temporarily unavailable"
  retry_on Errno::EAGAIN, wait: 5.minutes, attempts: 3

  def large_file?(path)
    File.size(path) > FileTracker.large_file_threshhold
  rescue Errno::ENOENT => e
    false
  end

  before_perform do |job|
    ActiveRecord::Base.clear_active_connections!
  end

end
