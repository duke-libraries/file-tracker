class TrackedDirectory < ActiveRecord::Base

  include TrackedDirectoryAdmin

  before_validation :normalize_path!
  validates :path, directory_exists: true, readable: true, uniqueness: true
  after_create :track!

  def self.update_all
    all.each(&:track!)
  end

  def self.update(id)
    find(id).track!
  end

  def listener
    ListenerFactory.call(path)
  end

  def to_s
    path
  end

  def tracked_files
    TrackedFile.under(path)
  end

  def count
    tracked_files.count
  end

  def size
    tracked_files.sum(:size)
  end

  def track!
    TrackDirectoryJob.perform_later(path)
    self.tracked_at = DateTime.now
    save!
    self
  end

  private

  def normalize_path!
    self.path = File.realdirpath(path)
  end

end
