class TrackFilesJob < ApplicationJob

  queue_as :files

  def perform(dir)
    entries = Dir.entries(dir).map { |f| File.absolute_path(f, dir) }
    files = entries.select { |f| File.file?(f) }
    tracked_files = TrackedFile.under(dir).pluck(:path)
    untracked_files = files - tracked_files
    TrackedFile.track!(*untracked_files) if untracked_files.present?
  end

end
