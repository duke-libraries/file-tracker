class CheckFixityJob < ApplicationJob

  queue_as :fixity_check

  def perform(tracked_file)
    tracked_file.check_fixity!
  end

end
