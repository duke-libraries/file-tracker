class InventoryJob < BatchJob

  def self.perform(id = nil)
    if id
      TrackDirectoryJob.enqueue_directory(TrackedDirectory.find(id))
    else
      TrackedDirectory.find_each { |dir| TrackDirectoryJob.enqueue_directory(dir) }
    end
  end

end
