namespace :file_tracker do
  desc "Track directory (initiate or update) at the given path."
  task :track, [:path] => :environment do |t, args|
    dir = TrackedDirectory.track!(args[:path], async: true)
    puts "Tracking job queued for #{dir}."
  end

  desc "Update tracked directory by ID (list IDs with `rake file_tracker:list`)."
  task :update, [:id] => :environment do |t, args|
    dir = TrackedDirectory.find(args[:id].to_i)
    dir.track!(async: true)
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
  end
end
