namespace :file_tracker do
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

  desc "Delete all tracked directories and files from the database."
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

  desc "Track directory at the given path."
  task :track, [:path] => :environment do |t, args|
    dir = TrackedDirectory.create!(path: args[:path])
    puts "Tracking job queued for #{dir}."
  end

  desc "Update tracked directory by ID (list IDs with `rake file_tracker:list`)."
  task :update, [:id] => :environment do |t, args|
    dir = TrackedDirectory.find!(args[:id].to_i)
    dir.track!
    puts "Tracking job queued for #{dir}."
  end

  desc "Run batch fixity check routine."
  task :fixity => :environment do
    queued = BatchFixity.call
    puts "#{queued} fixity check jobs queued."
  end

  desc "Show count of files tracked under path."
  task :count, [:path] => :environment do |t, args|
    count = TrackedFile.under(args[:path]).count
    puts "#{count} files tracked under path #{args[:path] || '/'}."
  end

  desc "List tracked directories."
  task :list => :environment do
    require 'csv'
    CSV($stdout, col_sep: "\t", headers: %w( ID PATH ), write_headers: true) do |csv|
      TrackedDirectory.pluck(:id, :path).each do |rec|
        csv << rec
      end
    end
  end

  namespace :queues do
    desc "Print status of QueueManager."
    task :status => :environment do
      if QueueManager.running?
        puts "QueueManager is running."
      else
        puts "QueueManager is stopped."
      end
    end

    desc "Start background job queues."
    task :start => :environment do
      if QueueManager.start
        while !QueueManager.running?
          sleep 1
        end
        puts "QueueManager started."
      else
        puts "QueueManager already running."
      end
    end

    desc "Stop background job queues."
    task :stop => :environment do
      if QueueManager.stop
        while QueueManager.running?
          sleep 1
        end
        puts "QueueManager stopped."
      else
        puts "QueueManager not running."
      end
    end

    desc "Restart background job queues."
    task :restart => [:stop, :start] do
      # puts "QueueManager restarted."
    end

    desc "Reload background job queue configuration."
    task :reload => :environment do
      if QueueManager.reload
        puts "QueueManager configuration reloaded."
      else
        puts "QueueManager not running."
      end
    end

    desc "Kill workers immediately and fail running jobs."
    task :kill_workers => :environment do
      count = QueueManager.kill_workers
      puts "#{count} QueueManager workers killed."
    end
  end
end
