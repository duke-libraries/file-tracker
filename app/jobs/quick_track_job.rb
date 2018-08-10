class QuickTrackJob < BatchJob

  def self.perform(id = nil)
    relation = id ? TrackedDirectory.find(id).tracked_files : TrackedFile.all
    relation.find_each { |tf| TrackFileJob.enqueue_file(tf) }
  end

end
