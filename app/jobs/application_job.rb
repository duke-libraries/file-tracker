require 'file_tracker/utils'

class ApplicationJob < ActiveJob::Base

  include FileTracker::Utils

  before_perform do |job|
    ActiveRecord::Base.clear_active_connections!
  end

end
