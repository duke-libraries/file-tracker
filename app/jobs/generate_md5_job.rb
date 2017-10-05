class GenerateMD5Job < FixityJob

  self.base_queue = :generate_md5
  self.large_file_queue = :generate_md5_large

  before_perform do |job|
    throw(:abort) if tracked_file.md5?
  end

  def perform(tracked_file)
    tracked_file.set_md5!
  end

end
