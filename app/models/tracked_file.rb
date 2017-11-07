class TrackedFile < ActiveRecord::Base

  include HasFixity
  include HasStatus
  include TrackedFileAdmin

  has_many :fixity_checks, dependent: :destroy
  has_many :tracked_changes, dependent: :destroy

  validates :path, file_exists: true, readable: true, uniqueness: true, on: :create
  validates_inclusion_of :status, in: FileTracker::Status.values

  before_save :set_size, unless: :size?
  before_save :reset_duracloud_attributes, if: [:persisted?, :md5_changed?]
  after_save :generate_sha1, if: :generate_sha1?
  after_save :generate_md5, if: :generate_md5?

  scope :large, ->{ where("size >= ?", FileTracker.large_file_threshhold) }
  scope :duracloud, ->(v) { where(duracloud_status: DuracloudCheck.const_get(v.to_s.upcase)) }

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

  def tracked_directory
    TrackedDirectory.where("path = substr(?, 1, length(path))", path).first
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

  def duracloud_checkable?
    persisted? && md5? && ok? && tracked_directory.duracloud_space?
  end

  def generate_digest?(digest)
    send "generate_#{digest}?"
  end

  def generate_sha1?
    !sha1? && ok?
  end

  def generate_sha1
    generate_digest :sha1
  end

  def generate_md5?
    !md5? && sha1? && ok?
  end

  def generate_md5
    generate_digest :md5
  end

  def generate_digest(digest)
    queue = large? ? :digest_large : :digest
    Resque.enqueue_to(queue, GenerateDigestJob, id, digest)
  end

  def set_digest!(digest)
    set_digest(digest)
    check_size
    commit_digest(digest)
  rescue FileTracker::ModifiedFileError => e # raised by check_size
    rollback_digest(digest)
    track_modification(e)
  rescue Errno::ENOENT => e
    track_deletion(e)
  end

  def set_sha1!
    set_digest! :sha1
  end

  def set_md5!
    set_digest! :md5
  end

  def check_fixity?
    fixity_checkable? && (!fixity_checked? || fixity_check_due?)
  end

  def check_fixity!
    if fixity_checkable?
      FixityCheck.call(self)
    else
      raise FileTracker::FixityError,
            "Tracked file #{id} cannot be fixity checked: #{tracked_file.inspect}"
    end
  end

  def check_duracloud!
    if duracloud_checkable?
      DuracloudCheck.call(self)
    else
      raise FileTracker::Error,
            "Tracked file #{id} cannot be checked in DuraCloud: #{tracked_file.inspect}"
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
    check_size
  rescue FileTracker::ModifiedFileError => e
    track_modification(e)
  rescue Errno::ENOENT => e
    track_deletion(e)
  end

  def check_size
    actual_size = calculate_size
    if size != actual_size
      raise FileTracker::ModifiedFileError,
            I18n.t("file_tracker.error.modification.size",
                       expected: size,
                       actual: actual_size)
    end
  end

  def track_deletion(exception)
    raise exception if new_record?
    missing!
    save! if changed?
    TrackedChange.create_deletion!(tracked_file: self)
  end

  def track_modification(exception)
    raise exception if new_record?
    modified!
    save! if changed?
    TrackedChange.create_modification(tracked_file: self,
                                      message: exception.message)
  end

  def reset!
    reset_fixity
    ok!
  end

  private

  def reset_duracloud_attributes
    assign_attributes(
      duracloud_status: DuracloudCheck::NOT_CHECKED,
      duracloud_checked_at: nil
    )
  end

  def commit_digest(digest)
    if send("#{digest}_changed?")
      save!
    end
  end

  def rollback_digest(digest)
    if send("#{digest}_changed?")
      self.attributes = { digest => send("#{digest}_was") }
    end
  end

end
