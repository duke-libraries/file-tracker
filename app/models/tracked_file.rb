class TrackedFile < ActiveRecord::Base

  include HasFixity
  include TrackedFileAdmin

  validates :path, file_exists: true, readable: true, uniqueness: true
  validates_inclusion_of :fixity_status, in: FileTracker::Status.values, allow_nil: true

  before_create :set_size, unless: :size
  after_create :generate_sha1, unless: :sha1

  scope :fixity_checkable, ->{ where.not(sha1: nil) }
  scope :fixity_status, ->(v) { where(fixity_status: v) }
  scope :not_ok, ->{ where("fixity_status > 0") }
  scope :fixity_not_checked, ->{ fixity_checkable.where(fixity_checked_at: nil) }
  scope :fixity_checked, -> { where.not(fixity_checked_at: nil) }
  scope :fixity_check_due, ->{ where("fixity_checked_at < ?", fixity_check_cutoff_date) }

  %i( ok altered missing error ).each do |status|
    scope status, ->{ fixity_status FileTracker::Status.send(status) }
  end

  def self.track!(*paths)
    paths.each { |path| find_or_create_by!(path: path) }
  end

  def self.under(path)
    return all if path.blank? || path == "/"
    value = File.realpath(path)
    where("path LIKE ?", "#{value}/%")
  end

  def self.fixity_check_cutoff_date
    DateTime.now - FileTracker.fixity_check_period.days
  end

  def to_s
    path
  end

  def generate_sha1
    GenerateSHA1Job.perform_later(self)
  end

  def generate_md5
    GenerateMD5Job.perform_later(self)
  end

  def check_fixity!
    check_fixity.tap do |result|
      self.fixity_checked_at = result.checked_at
      self.fixity_status = result.status
      save
    end
  end

  def check_fixity
    FixityCheck.call(self)
  end

end
