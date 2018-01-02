class AcceptPendingChangeJob < ApplicationJob

  self.queue = :inventory

  def self.perform(tracked_change_id)
    tracked_change = TrackedChange.find(tracked_change_id)
    tracked_change.accept!
  end

end
