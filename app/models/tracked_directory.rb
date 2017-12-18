require 'pathname'

class TrackedDirectory < ApplicationRecord

  include TrackedDirectoryAdmin

  has_many :tracked_files, dependent: :destroy
  before_validation :sanitize_path!
  validates :path, directory_exists: true, absolute_path: true, readable: true, uniqueness: true

  def to_s
    path
  end

  def pathname
    Pathname.new(path)
  end

  def count
    tracked_files.count
  end

  def size
    tracked_files.sum(:size)
  end

  def pending_changes
    TrackedChange.joins("INNER JOIN tracked_files ON tracked_changes.tracked_file_id = tracked_files.id")
      .where(tracked_changes: { change_status: FileTracker::Change::PENDING },
             tracked_files: { tracked_directory: self })
  end

  def track!
    self.tracked_at = DateTime.now
    track
    save!
    self
  end

  def track
    IO.popen("find . -type f -not -empty", chdir: path) do |io|
      while io.gets
        TrackedFile.track!(self, $_.chomp)
      end
    end
  end

  def sanitize_path!
    self.path = pathname.cleanpath.to_s
  end

end
