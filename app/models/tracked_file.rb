class TrackedFile < ActiveRecord::Base

  include HasFixity
  include TrackedFileAdmin

  has_many :fixity_checks, dependent: :destroy
  has_many :tracked_changes, dependent: :destroy

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

  FileTracker::Status.keys.each do |key|
    scope key, ->{ fixity_status FileTracker::Status.send(key) }

    value = FileTracker::Status.send(key)

    define_method "#{key}?" do
      fixity_status == value
    end

    define_method "#{key}!" do
      self.fixity_status = value
    end
  end

  def self.track!(*paths)
    paths.each { |path| find_or_initialize_by(path: path).track! }
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
    FixityCheck.call(self)
  end

  def track!
    if new_record?
      save!
    elsif ok? || fixity_status.nil?
      check_size!
    end
  end

  def check_size!
    if size != (current_size = calculate_size)
      # Don't track the same change twice ...
      TrackedChange.find_or_create_by(tracked_file: self, change_type: FileTracker::Change::MODIFICATION, size: current_size)
      # XXX update fixity_status to MODIFIED ?
    end
  end

end
