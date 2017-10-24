class InventoryJob < BatchJob

  def self.perform
    TrackedDirectory.all.each(&:track!)
  end

end
