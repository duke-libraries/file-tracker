class GenerateSHA1Job < FixityJob

  def perform(tracked_file)
    tracked_file.set_sha1!
  end

end
