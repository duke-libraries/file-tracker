require 'file_tracker/version'
require 'file_tracker/constants'
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
