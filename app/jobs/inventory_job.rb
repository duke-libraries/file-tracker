class InventoryJob < BatchJob

  def self.perform
    TrackedDirectory.all.each do |tracked_dir|
      Resque.enqueue(TrackDirectoryJob, tracked_dir.id)
    end
  end

end
