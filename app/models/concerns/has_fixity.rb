#
# Required attrs: path, size, md5, sha1.
#
module HasFixity

  def fixity
    Fixity.new(md5, sha1)
  end

  def fixity=(fxty)
    self.md5 = fxty.md5
    self.sha1 = fxty.sha1
  end

  def set_fixity
    self.fixity = calculate_fixity
  end

  def set_size
    self.size = calculate_size
  end

  def calculate_size
    File.size(path)
  end

  def calculate_fixity
    Fixity.calculate(path)
  end

  def has_fixity?
    fixity.complete?
  end

end
