namespace :file_tracker do
  desc "Track directory at the given path."
  task :track, [:path] => :environment do |t, args|
    TrackedDirectory.track!(args[:path])
  end
end
