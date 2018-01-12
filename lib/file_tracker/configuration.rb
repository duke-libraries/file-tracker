module FileTracker
  class Configuration
    include Singleton

    attr_accessor :after_sign_out_path,
                  :batch_fixity_check_limit,
                  :check_last_seen_period,
                  :fixity_check_period,
                  :large_file_threshhold,
                  :log_dir,
                  :log_shift_age

  end
end
