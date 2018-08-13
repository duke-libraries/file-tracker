require 'find'

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
    self.tracked_at = DateTime.now
    Resque.enqueue(TrackDirectoryJob, path)
    save!
    self
  end

  private

  def normalize_path!
    self.path = File.realdirpath(path)
  end

end
