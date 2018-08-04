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
    IO.popen(["find", path, "-type", "f", "-not", "-empty"]) do |io|
      while io.gets
        file_path = $_.chomp
        tf = TrackedFile.new(path: file_path)
        begin
          tf.set_size
        rescue Errno::EINVAL, Errno::ENOENT => e
          tf.log(:error, e.message)
        else
          queue = TrackFileJob.queue_for_tracked_file(tf)
          Resque.enqueue_to(queue, TrackFileJob, file_path)
        end
      end
    end
  end

  private

  def normalize_path!
    self.path = File.realdirpath(path)
  end

end
