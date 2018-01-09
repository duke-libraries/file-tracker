require 'logger'
require 'csv'

class TrackedChange < ActiveRecord::Base

  CHANGE_LOG_DEV = File.join(Rails.root, "log", "#{Rails.env}-changes.log") # log/production-changes.log
  CHANGE_LOG = ::Logger.new(CHANGE_LOG_DEV, 'weekly').tap do |logger|
    logger.formatter = proc { |severity, datetime, progname, msg| msg + "\n" }
  end

  include FileTracker::Change
  include HasFixity
  include TrackedChangeAdmin

  belongs_to :tracked_file
  delegate :path, :tracked_directory, to: :tracked_file

  validates_presence_of :tracked_file, :discovered_at
  validates_inclusion_of :change_type, in: FileTracker::Change::Type.values
  validates_inclusion_of :change_status, in: FileTracker::Change::Status.values

  before_validation :set_discovered_at, unless: :discovered_at?
  before_create :set_size, unless: :size?, if: :modification?
  after_create :log_change

  def accept!
    if modification?
      accept_modification
    elsif deletion?
      accept_deletion
    end
  end

  def reject!
    rejected!
    save!
  end

  FileTracker::Change::Type.each do |key, value|
    scope key, ->{ where(change_type: value) }

    define_singleton_method "create_#{key}" do |arg|
      create(arg.merge(change_type: value))
    end

    define_singleton_method "create_#{key}!" do |arg|
      create!(arg.merge(change_type: value))
    end

    define_method "#{key}?" do
      change_type == value
    end

    define_method "#{key}!" do |message = nil|
      self.change_type = value
      self.message = message if message
    end
  end

  FileTracker::Change::Status.each do |key, value|
    scope key, ->{ where(change_status: value) }

    define_method "#{key}?" do
      change_status == value
    end

    define_method "#{key}!" do
      self.change_status = value
    end
  end

  def change_type_label
    I18n.t("file_tracker.change.type.#{change_type}")
  end

  private

  def accept_modification
    tracked_file.reset!
    accepted!
    save!
  end

  def accept_deletion
    tracked_file.destroy # destroys all tracked changes related to tracked file!
  end

  def set_discovered_at
    self.discovered_at = DateTime.now
  end

  def log_change
    CHANGE_LOG.info(log_message)
  end

  def log_message
    [ discovered_at.to_formatted_s(:iso8601), change_type_label, path ].join("\t")
  end

end
