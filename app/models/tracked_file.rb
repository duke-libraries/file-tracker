class TrackedFile < ActiveRecord::Base

  include HasFixity
  include TrackedFileAdmin

  has_many :fixity_checks, dependent: :destroy
  has_many :tracked_changes, dependent: :destroy

  validates :path, file_exists: true, readable: true, uniqueness: true
  validates_inclusion_of :fixity_status, in: FileTracker::Status.values, allow_nil: true

  before_create :set_size, unless: :size?
  after_create :generate_sha1, unless: :sha1?

  scope :fixity_status, ->(v) { where(fixity_status: v) }
  scope :not_ok, ->{ where("fixity_status > ?", FileTracker::Status::OK) }
  scope :large, ->{ where("size >= ?", FileTracker.large_file_threshhold) }

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

  def self.check_fixity?
    where("sha1 IS NOT NULL AND (fixity_checked_at IS NULL OR fixity_checked_at < ?)",
          fixity_check_cutoff_date)
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

  def large?
    size? && size >= FileTracker.large_file_threshhold
  end

  def fixity_check_due?
    fixity_checked? &&
      fixity_checked_at < self.class.fixity_check_cutoff_date
  end

  def fixity_checkable?
    persisted? && sha1?
  end

  def fixity_checked?
    fixity_checked_at?
  end

  def generate_sha1
    GenerateSHA1Job.perform_later(self)
  end

  def generate_md5
    GenerateMD5Job.perform_later(self)
  end

  def set_sha1!
    super
  rescue Errno::ENOENT => e
    raise if new_record?
    missing!
    save if changed?
    TrackedChange.find_or_create_by(tracked_file: self,
                                    change_type: FileTracker::Change::DELETION,
                                    change_status: nil)
  end

  def check_fixity?
    fixity_checkable? && (!fixity_checked? || fixity_check_due?)
  end

  def check_fixity!
    if fixity_checkable?
      FixityCheck.call(self)
    else
      raise FileTracker::FixityError, "Tracked file #{id} cannot be fixity checked: #{tracked_file.inspect}"
    end
  end

  def track!
    if new_record?
      save!
    elsif ok? || fixity_status.nil?
      check_size!
    end
  end

  def check_size!
    current_size = calculate_size
    if size != current_size
      modified!
      save if changed?
      TrackedChange.find_or_create_by(tracked_file: self,
                                      change_type: FileTracker::Change::MODIFICATION,
                                      size: current_size)
    end
  end

end
