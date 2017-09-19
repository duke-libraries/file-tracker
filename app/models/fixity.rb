Fixity = Struct.new(:size, :md5, :sha1) do

  def self.calculate(path)
    md5, sha1 = Digest::MD5.new, Digest::SHA1.new
    File.open(path, "rb") do |f|
      while buf = f.read(16384)
        md5  << buf
        sha1 << buf
      end
    end
    new(File.size(path), md5.hexdigest, sha1.hexdigest)
  end

end
