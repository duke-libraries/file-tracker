require 'file_tracker'

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

  desc "Track a new directory at the given path."
  task :track, [:path] => :environment do |t, args|
    dir = TrackedDirectory.create!(path: args[:path])
    puts "Tracking job queued for #{dir}."
  end

  desc "Update a tracked directory by ID (list IDs with `rake file_tracker:list`)."
  task :update, [:id] => :environment do |t, args|
    dir = TrackedDirectory.update(args[:id].to_i)
    puts "Tracking job queued for #{dir}."
  end

  desc "Update all tracked directories."
  task :update_all => :environment do
    TrackedDirectory.update_all
    puts "All tracked directories have been queued for updating."
  end

  desc "Show the count of files tracked under a path."
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

  desc "List status codes and translations."
  task :status => :environment do
    FileTracker::Status.values.each do |value|
      puts [ value.to_s, I18n.t("file_tracker.status.#{value}") ].join("\t")
    end
  end

  namespace :fixity do
    desc "Run the batch fixity check routine, optionally overriding the default limit (#{FileTracker.batch_fixity_check_limit})."
    task :check, [:max] => :environment do |t, args|
      BatchFixityCheckJob.perform_later(args[:max])
      puts "Batch fixity check job queued."
    end

    desc "Print a summary report of fixity status."
    task :summary => :environment do
      FixitySummary.call.each do |status, count|
        puts "#{status}\t#{count}"
      end
    end
  end

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
