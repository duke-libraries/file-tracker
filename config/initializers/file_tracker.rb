require 'file_tracker'

FileTracker.batch_fixity_check_limit = ENV.fetch("BATCH_FIXITY_CHECK_LIMIT", 10**5).to_i
FileTracker.fixity_check_period      = ENV.fetch("FIXITY_CHECK_PERIOD", 60).to_i
FileTracker.large_file_threshhold    = ENV.fetch("LARGE_FILE_THRESHHOLD", 10**9).to_i
FileTracker.after_sign_out_path      = ENV.fetch("AFTER_SIGN_OUT_PATH", "/")
