require 'digest'

module HasFixity

  def set_sha1
    self.sha1 = calculate_sha1
  end

  def set_md5
    self.md5 = calculate_md5
  end

  def set_size
    self.size = calculate_size
  end

  def calculate_size
    File.size(path)
  end

  def calculate_sha1
    Digest::SHA1.file(path).hexdigest
  end

  def calculate_md5
    Digest::MD5.file(path).hexdigest
  end

end
