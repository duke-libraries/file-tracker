class InventoryJob < ApplicationJob

  self.queue = :batch

  def self.perform
    TrackedDirectory.all.each(&:track!)
  end

end
