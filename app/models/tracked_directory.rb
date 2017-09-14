class TrackedDirectory < ActiveRecord::Base
  include TrackedDirectoryDisplay
  include TrackedDirectoryAdmin

  before_validation :normalize_path!
  validates_uniqueness_of :path

  def self.track!(path)
    find_or_create_by!(path: path).tap { |dir| dir.track! }
  end

  def to_s
    path
  end

  # def new_files
  #   all_files.lazy.reject { |f| TrackedFile.exists?(path: f) }
  # end

  # def all_files
  #   find.lazy.select { |f| File.file?(f) }
  # end

  # def dirs
  #   find.lazy.reject { |d| Dir.empty?(d) }
  # end

  # def find
  #   Find.find(path)
  # end

  def tracked_files
    TrackedFile.under(path)
  end

  def count
    tracked_files.count
  end

  def size
    tracked_files.sum(:size)
  end

  # def has_tracked_files?
  #   tracked_files.exists?
  # end

  def track!
    TrackChildrenJob.perform_later(path)
    self.tracked_at = DateTime.now
    save!
  end

  # def track_dirs
  #   dirs.each { |dir| TrackChildrenJob.perform_later(dir) }
  # end

  # def track_files
  #   new_files.each { |file| TrackFileJob.perform_later(file) }
  # end

  private

  def normalize_path!
    self.path = File.realdirpath(path)
  end

end
