require 'digest'

class Digests

  BUFSIZE = 16384

  attr_reader :path, :md5, :sha1

  def initialize(path, md5 = nil, sha1 = nil)
    @path = path
    @md5  = md5
    @sha1 = sha1
    calculate unless md5 && sha1
  end

  def ==(other)
    path == other.path &&
      md5 == other.md5 &&
      sha1 == other.sha1
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
