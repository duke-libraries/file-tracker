class FixityCheck < ActiveRecord::Base

  include FileTracker::Status
  include HasFixity
  include FixityCheckResultAdmin

  belongs_to :tracked_file

  validates_presence_of :started_at, :tracked_file
  validates_inclusion_of :status, in: FileTracker::Status.values

  delegate :path, to: :tracked_file

  after_create :update_tracked_file
  after_create :track_change, if: :track_change?

  def self.call(tracked_file)
    new(tracked_file: tracked_file).tap do |fixity_check|
      fixity_check.execute
    end
  end

  %w( ok modified missing error ).each do |stat|
    value = FileTracker::Status.send(stat)

    define_method "#{stat}?" do
      status == value
    end

    define_method "#{stat}!" do |message = nil|
      self.status = value
      self.message = message if message
    end
  end

  def execute
    start
    begin
      check
    ensure
      finish
    end
  end

  def start
    self.started_at = DateTime.now
  end

  def finish
    self.finished_at = DateTime.now
    save!
  end

  def check
    begin
      check_size
      check_sha1
    rescue FileTracker::ModifiedFileError => e
      modified!(e.message)
    rescue Errno::ENOENT => e # file does not exist
      missing!
    rescue Errno::EACCES => e # permissions issue
      error!(e.inspect)
    else
      ok!
    end
  end

  def check_size
    set_size
    unless size == tracked_file.size
      raise FileTracker::ModifiedFileError,
            "Expected size: #{tracked_file.size}; actual size: #{size}"
    end
  end

  def check_sha1
    set_sha1
    unless sha1 == tracked_file.sha1
      raise FileTracker::ModifiedFileError,
            "Expected SHA1 {#{tracked_file.sha1}}; actual SHA1 {#{sha1}}"
    end
  end

  private

  def update_tracked_file
    tracked_file.update(fixity_checked_at: started_at, fixity_status: status)
  end

  def track_change?
    modified? || missing?
  end

  def track_change
    TrackedChange.create(tracked_file: tracked_file,
                         change_type: status,
                         size: size,
                         sha1: sha1,
                         discovered_at: started_at)
  end

end
