module FileTracker
  module Change

    module Type
      MODIFICATION = FileTracker::Status::MODIFIED
      DELETION     = FileTracker::Status::MISSING

      extend FileTracker::Constants
    end

    module Status
      PENDING  = -1
      ACCEPTED = 0
      REJECTED = 1

      extend FileTracker::Constants
    end

    include Type
    include Status

  end
end
