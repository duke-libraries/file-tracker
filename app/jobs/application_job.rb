require 'find'

class ApplicationJob < ActiveJob::Base

  class_attribute :large_file_threshhold
  self.large_file_threshhold = ENV.fetch("LARGE_FILE_THRESHHOLD", 10**9).to_i

  def large_file?(path)
    File.size(path) > large_file_threshhold
  rescue Errno::ENOENT => e
    false
  end

  before_perform do |job|
    ActiveRecord::Base.clear_active_connections!
  end

end
