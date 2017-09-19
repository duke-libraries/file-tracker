class GenerateFixityJob < FixityJob

  def perform(tracked_file)
    tracked_file.generate_fixity!
  end

end
