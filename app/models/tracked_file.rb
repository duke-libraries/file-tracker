class TrackedFile < ActiveRecord::Base
  include TrackedFileDisplay
  include TrackedFileAdmin

  # fixity status
  OK      = 0
  CHANGED = 1
  MISSING = 2

  validates_presence_of :md5, :sha1, :size
  validates :path, file_exists: true, uniqueness: true

  def self.track!(path)
    create! calculate_fixity(path).to_h
  end

  def self.under(path)
    return all if path.blank? || path == "/"
    value = File.realpath(path)
    where("path LIKE ?", "#{value}/%")
  end

  def self.calculate_fixity(path)
    Fixity.calculate(path)
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
    self.class.calculate_fixity(path)
  end

end
