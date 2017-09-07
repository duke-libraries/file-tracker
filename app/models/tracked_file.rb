class TrackedFile < ActiveRecord::Base
  include TrackedFileDisplay
  include TrackedFileAdmin

  # fixity status
  OK      = 0
  CHANGED = 1
  MISSING = 2

  validates_presence_of :md5, :sha1, :size, :path
  validates_uniqueness_of :path

  Fixity = Struct.new(:path, :size, :md5, :sha1) do
    def self.calculate(path)
      md5, sha1 = Digest::MD5.new, Digest::SHA1.new
      File.open(path, "rb") do |f|
        while buf = f.read(16384)
          md5  << buf
          sha1 << buf
        end
      end
      new(path, File.size(path), md5.hexdigest, sha1.hexdigest)
    end
  end

  def self.under(path)
    value = File.realpath(path || "/")
    where("path LIKE ?", "#{value}%")
  end

  def to_s
    path
  end

  def fixity_check!
    self.fixity_checked_at = DateTime.now
    self.fixity_status = fixity_check
    save!
  end
  alias_method :check_fixity!, :fixity_check!

  def fixity_check
    fixity == calculate_fixity ? OK : CHANGED
  rescue Errno::ENOENT => e
    MISSING
  end
  alias_method :check_fixity, :fixity_check

  def fixity
    @fixity ||= Fixity.new(path, size, md5, sha1)
  end

  def calculate_fixity
    Fixity.calculate(path)
  end

end
