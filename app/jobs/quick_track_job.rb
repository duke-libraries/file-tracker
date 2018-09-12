class QuickTrackJob < BatchJob

  def perform(id = nil)
    relation = id ? TrackedDirectory.find(id).tracked_files : TrackedFile.all
    relation.find_each { |tf| TrackFileJob.perform_later(tf.path) }
  end

end
