class QuickTrackJob < BatchJob

  def self.perform(id = nil)
    relation = id ? TrackedDirectory.find(id).tracked_files : TrackedFile.all
    relation.find_each do |tf|
      queue = TrackFileJob.queue_for_tracked_file(tf)
      Resque.enqueue_to(queue, TrackFileJob, tf.path)
    end
  end

end
