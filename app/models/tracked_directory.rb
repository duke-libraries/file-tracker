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

  def duracloud_checkable_files
    tracked_files.ok.where.not(md5: nil) if duracloud_checkable?
  end

  def duracloud_checkable?
    duracloud_space?
  end

  def check_duracloud!
    self.duracloud_checked_at = DateTime.now
    duracloud_checkable_files.each do |tracked_file|
      Resque.enqueue(DuracloudCheckJob, tracked_file.id)
    end
    save!
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
    IO.popen(["find", path, "-type", "f"]) do |io|
      while io.gets
        path = $_.chomp
        TrackedFile.track!(path)
      end
    end
  end

  private

  def normalize_path!
    self.path = File.realdirpath(path)
  end

end
