class GenerateMD5Job < FixityJob

  def perform(tracked_file)
    tracked_file.set_md5!
  end

end
