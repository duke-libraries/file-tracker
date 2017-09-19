class CheckFixityJob < FixityJob



  def perform(tracked_file)
    tracked_file.check_fixity!
  end

end
