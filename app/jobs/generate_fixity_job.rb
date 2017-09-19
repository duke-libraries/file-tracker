class GenerateFixityJob < ApplicationJob

  queue_as do
    tracked_file = self.arguments.first
    large_file?(tracked_file.path) ? :fixity_gen_large : :fixity_gen
  end

  def perform(tracked_file)
    tracked_file.generate_fixity!
  end

end
