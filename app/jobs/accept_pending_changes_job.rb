class AcceptPendingChangesJob < BatchJob

  def self.perform
    TrackedChange.pending.ids.each do |tracked_change_id|
      Resque.enqueue(AcceptPendingChangeJob, tracked_change_id)
    end
  end

end
