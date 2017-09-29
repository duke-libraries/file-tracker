module FileTracker
  module Change
    module Type
      MODIFICATION = FileTracker::Status::MODIFIED
      DELETION     = FileTracker::Status::MISSING
    end

    module Status
      PENDING  = nil
      ACCEPTED = 0
      REJECTED = 1
    end
  end
end
