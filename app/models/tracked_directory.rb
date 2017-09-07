class TrackedDirectory < ActiveRecord::Base
  include TrackedDirectoryAdmin

  before_validation :normalize_path
  validates_uniqueness_of :path

  def self.track!(path, async: false)
    find_or_create_by!(path: path).tap do |dir|
      dir.track!(async: async)
    end
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

  def tracked_files?
    tracked_files.exists?
  end

  def track!(async: false)
    if async
      TrackDirectoryJob.perform_later(self)
    else
      track
    end
  end

  def reset!
    warn <<-EOS
This operation will remove all tracked files associated with this directory!
It cannot be undone.
EOS
    print "Continue (y/N)? "
    answer = gets.chomp
    if answer == 'y'
      tracked_files.delete_all
      puts "Tracked files deleted."
    else
      puts "Operation aborted."
    end
  end

  def import(hashes)
    TrackedFile.import(Hashdeep::COLUMNS, hashes)
  end

  private

  def track
    service = tracked_files? ? NewFiles : Hashdeep
    hashes = service.hashes(path).to_a
    import(hashes)
    self.tracked_at = DateTime.now
    save!
  end

  def normalize_path
    self.path = File.realdirpath(path)
  end

end
