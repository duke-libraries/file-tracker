class ApplicationJob

  class_attribute :queue

  def self.dequeue_all
    Resque::Job.destroy(queue, self)
  end

  # See Resque README re: MySQL and Rails 4.x
  # (Rails 5 not mentioned as of 2017-10-20).
  def self.before_perform_00_clear_active_connections(*args)
    ActiveRecord::Base.clear_active_connections!
  end

end
