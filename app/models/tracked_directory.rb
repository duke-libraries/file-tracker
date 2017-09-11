require 'find'

class TrackedDirectory < ActiveRecord::Base
  include TrackedDirectoryDisplay
  include TrackedDirectoryAdmin

  before_validation :normalize_path
  validates_uniqueness_of :path

  def self.track!(path)
    find_or_create_by!(path: path).tap { |dir| dir.track! }
  end

  def to_s
    path
  end

  def new_files
    all_files.lazy.select { |f| TrackedFile.exists?(path: f) }
  end

  def all_files
    find.lazy.select { |f| File.file?(f) }
  end

  def find
    Find.find(path)
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

  def tracked_files?
    tracked_files.exists?
  end

  def track!
    track_files!
    self.tracked_at = DateTime.now
    save!
  end

  def track_files!
    files = tracked_files? ? new_files : all_files
    files.each { |file| TrackFileJob.perform_later(file) }
  end

  private

  def normalize_path
    self.path = File.realdirpath(path)
  end

end
