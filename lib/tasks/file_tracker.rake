require 'file_tracker'

namespace :file_tracker do
  desc "Quickly track known files, optionally limited by directory ID."
  task :quick_track, [:id] => :environment do |t, args|
    QuickTrackJob.perform_later(args[:id])
    puts "Quick track job enqueued."
  end

  desc "Inventory all tracked directories, or single directory by ID."
  task :inventory, [:id] => :environment do |t, args|
    if id = args[:id]
      TrackedDirectory.find(id).track!
    else
      TrackedDirectory.find_each { |dir| dir.track! }
    end
  end

  desc "Print application version."
  task :version => :environment do
    puts FileTracker::VERSION
  end

  desc "Tag version #{FileTracker::VERSION} and push to GitHub."
  task :tag => :environment do
    tag = "v#{FileTracker::VERSION}"
    comment = "FileTracker #{tag}"
    if system("git", "tag", "-a", tag, "-m", comment)
      system("git", "push", "origin", tag)
    end
  end

  # desc "Delete all tracked directories and files from the database."
  task :reset => :environment do
    warn <<-EOS

THIS OPERATION WILL REMOVE ALL TRACKED DIRECTORIES AND FILES FROM THE DATABASE!

IT CANNOT BE UNDONE!

EOS
    print "Continue (y/N)? "
    answer = $stdin.gets.chomp
    if answer == 'y'
      files = TrackedFile.delete_all
      puts "#{files} Tracked files deleted."
      dirs = TrackedDirectory.delete_all
      puts "#{dirs} Tracked directories deleted."
    else
      puts "Operation aborted."
    end
  end

  desc "Run the batch fixity check routine, optionally overriding the default limit (#{FileTracker.batch_fixity_check_limit})."
  task :fixity, [:max] => :environment do |t, args|
    BatchFixityCheckJob.perform_later(args[:max])
    puts "Batch fixity check job enqueued."
  end

end
