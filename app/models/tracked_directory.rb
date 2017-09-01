class TrackedDirectory < ActiveRecord::Base

  validates_uniqueness_of :path

  def self.track!(path)
    find_or_create_by!(path: path).tap do |dir|
      dir.track!
    end
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

  def track!
    service = tracked_files? ? NewFiles : Hashdeep
    hashes = service.hashes(path).to_a
    TrackedFile.import(Hashdeep::COLUMNS, hashes)
  end

  def reset!
    warn <<-EOS
This operation will remove all tracked files and associated fixity checks
related to this directory! It cannot be undone.
EOS
    print "Continue (y/N)? "
    answer = gets.chomp
    if answer == 'y'
      tracked_files.destroy_all
      puts "Tracked files destroyed."
    else
      puts "Operation aborted."
    end
  end

end
