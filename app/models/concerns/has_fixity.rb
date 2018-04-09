require 'digest'

module HasFixity

  RETRIABLE_IO_ERRORS = [ Errno::EAGAIN, Errno::EBADF, Errno::EIO, Errno::EBUSY ]

  def reset_fixity
    assign_attributes(sha1: nil, size: nil)
  end

  def fixity_s
    "[%s %s]" % [size_s, sha1_s]
  end

  def size_s
    size ? size.to_s : "-"
  end

  def sha1_s
    sha1 || "-"
  end

  def set_fixity
    set_size unless size?
    set_sha1 unless sha1?
  end

  def set_sha1
    self.sha1 = calculate_sha1
  end

  def set_size
    self.size = calculate_size
  end

  def calculate_size
    RetryOnError.wrap(RETRIABLE_IO_ERRORS, wait: 60) do
      File.size(path)
    end
  end

  def calculate_sha1
    RetryOnError.wrap(RETRIABLE_IO_ERRORS, wait: 60) do
      Digest::SHA1.file(path).hexdigest
    end
  end

end
