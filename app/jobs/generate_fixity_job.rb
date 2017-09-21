class GenerateFixityJob < FixityJob

  def perform(tracked_file)
    tracked_file.set_fixity
    tracked_file.save
  end

end
