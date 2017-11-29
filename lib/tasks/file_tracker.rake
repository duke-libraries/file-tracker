require 'file_tracker'

namespace :file_tracker do
  desc "Inventory tracked directory by ID, or all tracked directories (no `id`)."
  task :inventory, [:id] => :environment do |t, args|
    if args[:id]
      Resque.enqueue(TrackDirectoryJob, args[:id])
      puts "TrackDirectoryJob enqueued (id = #{args[:id]})."
    else
      Resque.enqueue(InventoryJob)
      puts "InventoryJob enqueued."
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

  desc "List status codes and translations."
  task :status => :environment do
    FileTracker::Status.values.each do |value|
      puts [ value.to_s, I18n.t("file_tracker.status.#{value}") ].join("\t")
    end
  end

  desc "Run the batch fixity check routine, optionally overriding the default limit (#{FileTracker.batch_fixity_check_limit})."
  task :fixity, [:max] => :environment do |t, args|
    Resque.enqueue(BatchFixityCheckJob, args[:max])
    puts "BatchFixityCheckJob enqueued."
  end

  task :duracloud, [:only_status] do |t, args|
    warn "[DEPRECATION] The `file_tracker:duracloud` task is deprecated." \
         " Use `file_tracker:duracloud:check` task instead."
    Rake::Task["file_tracker:duracloud:check"].invoke(*args)
  end

  namespace :duracloud do
    desc "Run the batch DuraCloud check routine, optionally limiting tracked_files by duracloud_status."
    task :check, [:status] => :environment do |t, args|
      Resque.enqueue(BatchDuracloudCheckJob, args[:status])
      print "BatchDuracloudCheckJob enqueued"
      print " for status #{args[:only_status]}" if args[:status]
      puts "."
    end

    desc "List paths of files having the provided duracloud_status, optionally limited by directory."
    task :list, [:status, :dir] => :environment do |t, args|
      puts TrackedFile.under(args[:dir]).duracloud(args[:status]).pluck(:path)
    end
  end # :duracloud

  namespace :queues do
    desc "Print the status of the QueueManager."
    task :status => :environment do
      if QueueManager.running?
        puts "QueueManager is running."
      else
        puts "QueueManager is stopped."
      end
    end

    desc "Start the QueueManager."
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

    desc "Stop the QueueManager."
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

    desc "Restart the QueueManager."
    task :restart => [:stop, :start] do
      # stop, start
    end

    desc "Reload the QueueManager configuration."
    task :reload => :environment do
      if QueueManager.reload
        puts "QueueManager configuration reloaded."
      else
        puts "QueueManager not running."
      end
    end

    desc "Kill QueueManager workers immediately and fail running jobs."
    task :kill_workers => :environment do
      count = QueueManager.kill_workers
      puts "#{count} QueueManager workers killed."
    end
  end
end
