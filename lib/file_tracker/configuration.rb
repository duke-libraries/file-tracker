module FileTracker
  class Configuration
    include Singleton

    attr_accessor :batch_fixity_check_limit,
                  :large_file_threshhold,
                  :fixity_check_period

  end
end
