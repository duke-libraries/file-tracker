module FileTracker
  module Status

    OK         = 0
    ALTERED    = 1
    MISSING    = 2
    ERROR      = 3

    def self.values
      @@value ||= constants(false).map { |c| const_get(c) }
    end

  end
end
