class CheckFixityJob < FixityJob

  self.base_queue = :check_fixity
  self.large_file_queue = :check_fixity_large

  def perform(tracked_file)
    tracked_file.check_fixity!
  end

end
