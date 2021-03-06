require 'file_tracker/version'
require 'file_tracker/constants'
require 'file_tracker/error'
require 'file_tracker/status'

module FileTracker

  mattr_accessor :batch_fixity_check_limit do
    ENV.fetch("BATCH_FIXITY_CHECK_LIMIT", 10**5).to_i
  end

  mattr_accessor :check_last_seen_period do
    ENV.fetch("CHECK_LAST_SEEN_PERIOD", 2).to_i
  end

  mattr_accessor :fixity_check_period do
    ENV.fetch("FIXITY_CHECK_PERIOD", 60).to_i
  end

  mattr_accessor :large_file_threshhold do
    ENV.fetch("LARGE_FILE_THRESHHOLD", 10**9).to_i
  end

  mattr_accessor :log_dir do
    ENV.fetch("FILE_TRACKER_LOG_DIR", Rails.root.join("log"))
  end

  mattr_accessor :log_shift_age do
    ENV.fetch("FILE_TRACKER_LOG_SHIFT_AGE", "weekly")
  end

  mattr_accessor :redis_namespace do
    ENV.fetch("REDIS_NAMESPACE", "resque:FileTracker")
  end

  mattr_accessor :log_file_errors do
    [ Errno::EINVAL, Errno::ENOENT, Errno::EACCES ]
  end

  mattr_accessor :track_directory_job do
    "TrackDirectoryFindJob"
  end

  def self.config
    @config ||= class_variables(false).each_with_object({}) do |var, memo|
      memo[var.to_s.sub("@@", "").to_sym] = class_variable_get(var)
    end.slice(:batch_fixity_check_limit, :check_last_seen_period, :fixity_check_period, :large_file_threshhold)
  end

end
