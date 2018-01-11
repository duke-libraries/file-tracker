class TrackedFile < ActiveRecord::Base

  include HasFixity
  include TrackedFileAdmin

  validates :path, file_exists: true, file_not_empty: true, readable: true, uniqueness: true, on: :create

  before_update if: :fixity_changed? do
    log("MODIFIED")
  end
  before_save :set_fixity
  after_create { log("ADDED") }
  after_destroy { log("REMOVED") }

  scope :large, ->{ where("size >= ?", FileTracker.large_file_threshhold) }

  def self.logger
    @logger ||= Logger.new(File.join(Rails.root, "log", "tracked-files.#{Rails.env}.log"), "weekly")
  end

  def self.check_fixity?
    where("fixity_checked_at IS NULL OR fixity_checked_at < ?", fixity_check_cutoff_date)
  end

  def self.track!(*paths)
    paths.each { |path| find_or_initialize_by(path: path).track! }
  end

  def self.under(path)
    return all if path.blank? || path == "/"
    value = path.sub(/\/\z/, "") # remove trailing slash
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
    new_record? ? save! : check_size!
  end

  def check_size!
    fixity_check = FixityCheck.call(self, only_size: true)
    if fixity_check.missing?
      destroy
    elsif fixity_check.modified?
      self.size = fixity_check.size
      self.sha1 = nil
      save!
    end
    self
  end

  private

  def log(msg)
    TrackedFile.logger << log_message(msg)
  end

  def log_message(msg)
    [ DateTime.now.to_s(:iso8601), msg, path, size, sha1 ].join("\t") + "\n"
  end

end
