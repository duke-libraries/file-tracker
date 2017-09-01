#
# Represents fixity information for a file
#
class Fixity

  BUFSIZE = 16384

  # fixity check outcomes
  OK      = 0
  CHANGED = 1
  MISSING = 2

  DISPLAY_STATUS = {
    OK      => "OK",
    CHANGED => "CHANGED",
    MISSING => "MISSING",
  }.freeze

  class_attribute :check_period
  self.check_period = 60

  def self.check(fixity)
    new(fixity.path).check(fixity)
  end

  attr_reader :path

  def initialize(path, md5 = nil, sha1 = nil, size = nil)
    @path, @md5, @sha1, @size = path, md5, sha1, size
  end

  def check(other)
    self == other ? OK : CHANGED
  rescue Errno::ENOENT => e
    MISSING
  end

  def size
    @size ||= File.size(path)
  end

  def md5
    calculate unless @md5
    @md5
  end

  def sha1
    calculate unless @sha1
    @sha1
  end

  def ==(other)
    self.path == other.path &&
      self.size == other.size &&
      self.md5 == other.md5 &&
      self.sha1 == other.sha1
  end

  private

  def calculate
    _md5  = Digest::MD5.new
    _sha1 = Digest::SHA1.new
    File.open(path, "rb") do |f|
      while buf = f.read(BUFSIZE)
        _md5 << buf
        _sha1 << buf
      end
    end
    @md5  = _md5.hexdigest
    @sha1 = _sha1.hexdigest
  end

end
