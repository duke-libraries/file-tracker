class TrackedFile < ActiveRecord::Base

  include HasFixity
  include HasStatus
  include TrackedFileAdmin

  has_many :fixity_checks, dependent: :destroy
  has_many :tracked_changes, dependent: :destroy

  validates :path, file_exists: true, readable: true, uniqueness: true
  validates_inclusion_of :status, in: FileTracker::Status.values

  before_create :set_size, unless: :size?
  after_create :generate_sha1, unless: :sha1?

  scope :large, ->{ where("size >= ?", FileTracker.large_file_threshhold) }

  def self.check_fixity?
    ok.where("sha1 IS NOT NULL AND (fixity_checked_at IS NULL OR fixity_checked_at < ?)",
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
    persisted? && sha1? && ok?
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
    track_deletion(e)
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
    elsif ok?
      check_size!
    end
  end

  def check_size!
    current_size = calculate_size
    if size != current_size
      modified!
      save if changed?
      message = I18n.t("file_tracker.error.modification.size",
                       expected: size,
                       actual: current_size)
      TrackedChange.create_modification!(tracked_file: self,
                                         size: current_size,
                                         message: message)
    end
  rescue Errno::ENOENT => e
    track_deletion(e)
  end

  def track_deletion(exception)
    raise exception if new_record?
    missing!
    save if changed?
    TrackedChange.create_deletion!(tracked_file: self)
  end

end
