class TrackedFile < ActiveRecord::Base

  LOGDEV = File.join(FileTracker.log_dir, "tracked-files.#{Rails.env}.log")

  include HasFixity
  include TrackedFileAdmin

  validates :path, file_exists: true, file_not_empty: true, readable: true, uniqueness: true, on: :create

  around_update :log_modified, if: :fixity_changed?
  before_save :set_fixity
  after_create { log("ADDED") }
  after_destroy { log("REMOVED") }

  scope :large, ->{ where("size >= ?", FileTracker.large_file_threshhold) }

  def self.logger
    @logger ||= Logger.new(LOGDEV, FileTracker.log_shift_age)
  end

  def self.track!(*paths)
    paths.each { |path| find_or_initialize_by(path: path).track! }
  end

  def self.under(path)
    return all if path.blank? || path == "/"
    value = path.sub(/\/\z/, "") # remove trailing slash
    where("path LIKE ?", "#{value}/%")
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

  def fixity_changed?
    size_changed? || sha1_changed?
  end

  def check_fixity!
    fixity_check = FixityCheck.call(self)
    if fixity_check.missing?
      destroy
    else
      self.fixity_checked_at = fixity_check.started_at
      if fixity_check.modified?
        self.size = fixity_check.size
        self.sha1 = fixity_check.sha1
      end
      save!
    end
    self
  end

  def track!
    if new_record?
      unless save
        msg = errors.full_messages.join("; ")
        log("ERROR", msg)
      end
    else
      check_size!
    end
  end

  def check_size!
    fixity_check = FixityCheck.call(self, only_size: true)
    if fixity_check.missing?
      destroy
    elsif fixity_check.modified?
      self.size = fixity_check.size
      self.sha1 = nil
      save!
    else
      touch
    end
    self
  end

  private

  def log(tag, msg = nil)
    TrackedFile.logger << log_message(tag, msg)
  end

  def log_message(tag, msg = nil)
    [ log_date, tag, path, size_s, sha1_s, msg ].join("\t") + "\n"
  end

  def log_date
    DateTime.now.to_s(:iso8601)
  end

  def log_modified
    msg = "Was: [#{size_was} #{sha1_was}]"
    yield
    log("MODIFIED", msg)
  end

end
