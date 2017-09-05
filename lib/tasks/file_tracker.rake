namespace :file_tracker do
  desc "Track directory (initiate or update) at the given path."
  task :track_directory, [:path] => :environment do |t, args|
    TrackDirectoryJob.perform_later(args[:path])
    puts "Tracking job queued for #{args[:path]}."
  end

  desc "Run batch fixity check routine."
  task :batch_fixity => :environment do
    queued = BatchFixity.call
    puts "#{queued} fixity check jobs queued."
  end

  desc "Show count of files tracked under path."
  task :count, [:path] => :environment do |t, args|
    count = TrackedFile.under(args[:path]).count
    puts "#{count} files tracked under path #{args[:path] || '/'}."
  end
end
