class CheckFixityJob < FixityJob

  self.base_queue = :check_fixity
  self.large_file_queue = :check_fixity_large

  before_enqueue do |job|
    throw(:abort) unless tracked_file.fixity_checkable?
  end

  before_perform do |job|
    throw(:abort) unless tracked_file.check_fixity?
  end

  def perform(tracked_file)
    tracked_file.check_fixity!
  end

end
