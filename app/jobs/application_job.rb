class ApplicationJob < ActiveJob::Base

  before_perform :clear_active_connections

  retry_on Errno::EADDRNOTAVAIL
  retry_on Errno::EBUSY
  retry_on Resque::DirtyExit if queue_adapter == :resque

  private

  # See Resque README re: MySQL and Rails 4.x
  # (Rails 5 not mentioned as of 2017-10-20).
  def clear_active_connections
    ActiveRecord::Base.clear_active_connections!
  end

end
