class InventoryJob < BatchJob

  def self.perform
    TrackedDirectory.pluck(:id).each do |id|
      Resque.enqueue(TrackDirectoryJob, id)
    end
  end

end
