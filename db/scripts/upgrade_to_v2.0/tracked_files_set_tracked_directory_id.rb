print "Setting tracked_directory_id for each row in tracked_files ... "
TrackedDirectory.all.each do |dir|
  files = TrackedFile.where("tracked_directory_id IS NULL and path LIKE ?", "#{dir.path}/%")
  files.update_all(tracked_directory_id: dir.id)
end
puts "DONE"
