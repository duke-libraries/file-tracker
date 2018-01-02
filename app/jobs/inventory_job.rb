class InventoryJob < BatchJob

  def self.perform
    TrackedDirectory.ids.each do |id|
      Resque.enqueue(TrackDirectoryJob, id)
    end
  end

end
