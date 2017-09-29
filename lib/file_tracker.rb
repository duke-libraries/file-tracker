require 'file_tracker/version'
require 'file_tracker/configuration'
require 'file_tracker/error'
require 'file_tracker/status'
require 'file_tracker/change'

module FileTracker
  def self.configuration
    Configuration.instance
  end

  def self.method_missing(name, *args, &block)
    configuration.send(name, *args, &block)
  end
end

FileTracker.batch_fixity_check_limit = ENV.fetch("BATCH_FIXITY_CHECK_LIMIT", 10**5).to_i
FileTracker.fixity_check_period      = ENV.fetch("FIXITY_CHECK_PERIOD", 60).to_i
FileTracker.large_file_threshhold    = ENV.fetch("LARGE_FILE_THRESHHOLD", 10**9).to_i
