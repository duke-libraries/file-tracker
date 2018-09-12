class TrackedDirectory < ActiveRecord::Base

  include TrackedDirectoryAdmin

  before_validation :normalize_path!
  validates :path, directory_exists: true, readable: true, uniqueness: true

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
    update!(tracked_at: DateTime.now)
  end

  private

  def normalize_path!
    self.path = File.realdirpath(path)
  end

end
