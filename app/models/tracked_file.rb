class TrackedFile < ActiveRecord::Base
  include TrackedFileDisplay
  include TrackedFileAdmin

  # fixity status
  OK      = 0
  CHANGED = 1
  MISSING = 2

  validates :path, file_exists: true, uniqueness: true
  after_create :generate_fixity_later, if: :generate_fixity?

  def self.track!(*paths)
    paths.each { |path| create!(path: path) }
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

  def generate_fixity?
    size.blank? || md5.blank? || sha1.blank?
  end

  def generate_fixity!
    update! calculate_fixity.to_h
  end

  def generate_fixity_later
    GenerateFixityJob.perform_later(self)
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
    @fixity ||= Fixity.new(size, md5, sha1)
  end

  def calculate_fixity
    self.class.calculate_fixity(path)
  end

end
