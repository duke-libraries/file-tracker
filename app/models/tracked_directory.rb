class TrackedDirectory < ActiveRecord::Base

  include HasPathname
  include TrackedDirectoryAdmin

  has_many :tracked_files, dependent: :destroy
  before_validation :normalize_path!
  validates :path, directory_exists: true, readable: true, uniqueness: true

  def to_s
    path
  end

  # @deprecated Use {#tracked_files} instead.
  def _tracked_files
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
        path = $_.chomp
        TrackedFile.track!(self, path)
      end
    end
  end

  private

  def normalize_path!
    self.path = File.realdirpath(path)
  end

end
