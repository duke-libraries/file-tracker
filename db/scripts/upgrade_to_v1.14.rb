#
# Upgrade script for v1.14
#
# Sets tracked_directory_id for each row in tracked_files.
#
TrackedDirectory.all.each do |dir|
  dir._tracked_files.update_all(tracked_directory_id: dir.id)
end
