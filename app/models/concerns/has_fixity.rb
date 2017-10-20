require 'digest'

module HasFixity

  def set_digest(digest)
    self.attributes = { digest => calculate_digest(digest) }
  end

  def set_sha1
    set_digest :sha1
  end

  def set_md5
    set_digest :md5
  end

  def set_size
    self.size = calculate_size
  end

  def calculate_size
    File.size(path)
  end

  def calculate_digest(digest)
    digest_class = Digest.const_get(digest.to_s.upcase)
    digest_class.file(path).hexdigest
  end

  def calculate_sha1
    calculate_digest :sha1
  end

  def calculate_md5
    calculate_digest :md5
  end

end
