class FixityCheckJob < ActiveJob::Base

  queue_as :fixity

  def perform(tracked_file)

  end

end
