class CheckFixityJob < ApplicationJob

  queue_as { tracked_file.large? ? :fixity_large : :fixity }

  def perform(tracked_file)
    tracked_file.check_fixity!
  end

  def tracked_file
    arguments.first
  end

end
