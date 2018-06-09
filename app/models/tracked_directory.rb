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
    track
    save!
    self
  end

  def track
    Find.find(path) do |f|
      if File.file?(f) && !File.symlink?(f)
        track_path(f)
      else
        next
      end
    end
  end

  private

  def track_path(file_path)
    tf = TrackedFile.new(path: file_path)
    tf.set_size
    queue = TrackFileJob.queue_for_tracked_file(tf)
    Resque.enqueue_to(queue, TrackFileJob, file_path)
  end

  def normalize_path!
    self.path = File.realdirpath(path)
  end

end
