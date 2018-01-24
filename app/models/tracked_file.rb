class TrackedFile < ActiveRecord::Base

  LOGDEV = File.join(FileTracker.log_dir, "tracked-files.#{Rails.env}.log")

  include HasFixity
  include TrackedFileAdmin

  validates :path, file_exists: true, file_not_empty: true, readable: true, uniqueness: true, on: :create

  around_update :log_modified, if: :fixity_changed?
  before_save :set_fixity
  after_create :log_created
  after_destroy :log_destroyed

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

  def identical_files
    tracked_directory.tracked_files.where("sha1 = ? and path != ?", sha1, path) rescue nil
  end

  def exist?
    File.exist?(path)
  end

  def removed?
    !exist?
  end

  private

  def log(tag, msg = nil)
    TrackedFile.logger << log_message(I18n.t("file_tracker.log.tag.#{tag}"), msg)
  end

  def log_message(tag, msg = nil)
    [ log_date, tag, path, size_s, sha1_s, msg ].join("\t") + "\n"
  end

  def log_date
    DateTime.now.to_s(:iso8601)
  end

  def log_modified
    msg = I18n.t("file_tracker.log.message.modified") % sha1_was
    yield
    log(:modified, msg)
  end

  def log_created
    if FileTracker.track_moves && other_file = moved_from
      msg = I18n.t("file_tracker.log.message.moved_from") % other_file.path
      log(:moved, msg)
      other_file.destroy
    else
      log(:added)
    end
  end

  def log_destroyed
    if FileTracker.track_moves && other_file = moved_to
      msg = I18n.t("file_tracker.log.message.moved_to") % other_file.path
      log(:moved, msg)
    else
      log(:removed)
    end
  end

  def only_identical_file
    other_files = identical_files.to_a
    other_files.length == 1 && other_files.first
  end

  def moved_from
    return false unless persisted?
    if other_file = only_identical_file
      other_file.removed? && other_file
    end
  end

  def moved_to
    return false unless destroyed?
    if other_file = only_identical_file
      other_file.exist? && other_file
    end
  end

end
