class QuickTrackJob < BatchJob

  def self.perform
    TrackedFile.find_each do |tf|
      queue = TrackFileJob.queue_for_tracked_file(tf)
      Resque.enqueue_to(queue, TrackFileJob, tf.path)
    end
  end

end
