#
# Upgrade script for v2.0
#
# bundle exec rails runner db/scripts/update_to_v2.0.rb
#

puts "Setting tracked_directory_id for each row in tracked_files ..."
TrackedDirectory.all.each do |dir|
  files = TrackedFile.where("path LIKE ?", "#{dir.path}/%")
  files.update_all(tracked_directory_id: dir.id)
end

puts "Updating TrackedFile paths to make relative ..."
TrackedFile.all.each do |file|
  file.sanitize_path!
  file.save!
end
