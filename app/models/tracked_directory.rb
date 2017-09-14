class TrackedDirectory < ActiveRecord::Base
  include TrackedDirectoryDisplay
  include TrackedDirectoryAdmin

  before_validation :normalize_path!
  validates :path, directory_exists: true, uniqueness: true

  def self.track!(path)
    find_or_create_by!(path: path).tap { |dir| dir.track! }
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
    TrackChildrenJob.perform_later(path)
    self.tracked_at = DateTime.now
    save!
  end

  private

  def normalize_path!
    self.path = File.realdirpath(path)
  end

end
