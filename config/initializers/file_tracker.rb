require 'file_tracker'
FileTracker.after_sign_out_path      = ENV.fetch("AFTER_SIGN_OUT_PATH", "/")
FileTracker.batch_fixity_check_limit = ENV.fetch("BATCH_FIXITY_CHECK_LIMIT", 10**5).to_i
FileTracker.check_last_seen_period   = ENV.fetch("CHECK_LAST_SEEN_PERIOD", 2).to_i
FileTracker.fixity_check_period      = ENV.fetch("FIXITY_CHECK_PERIOD", 60).to_i
FileTracker.large_file_threshhold    = ENV.fetch("LARGE_FILE_THRESHHOLD", 10**9).to_i
FileTracker.log_dir                  = ENV.fetch("FILE_TRACKER_LOG_DIR", File.join(Rails.root, "log"))
FileTracker.log_shift_age            = ENV.fetch("FILE_TRACKER_LOG_SHIFT_AGE", "weekly")

require 'resque'
Resque.redis.namespace = ENV.fetch("REDIS_NAMESPACE", "resque:FileTracker")
