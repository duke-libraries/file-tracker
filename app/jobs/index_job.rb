class IndexJob < ApplicationJob

  self.queue = :index

  def self.before_perform_abort_unless_index_enabled(*args)
    raise Resque::Job::DontPerform unless FileTracker.index_enabled
  end

end
