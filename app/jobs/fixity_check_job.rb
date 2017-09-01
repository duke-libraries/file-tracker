class FixityCheckJob < ActiveJob::Base

  queue_as :fixity

  def perform(tracked_file)
    tracked_file.fixity_check!
  end

end
