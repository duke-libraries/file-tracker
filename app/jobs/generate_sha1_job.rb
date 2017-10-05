class GenerateSHA1Job < FixityJob

  self.base_queue = :generate_sha1
  self.large_file_queue = :generate_sha1_large

  before_perform do |job|
    throw(:abort) if tracked_file.sha1?
  end

  def perform(tracked_file)
    tracked_file.set_sha1!
  end

end
