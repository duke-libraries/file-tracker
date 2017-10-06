class TrackedChange < ActiveRecord::Base

  include FileTracker::Change
  include HasFixity
  include TrackedChangeAdmin

  belongs_to :tracked_file

  delegate :path, to: :tracked_file

  validates_presence_of :tracked_file, :discovered_at
  validates_inclusion_of :change_type, in: FileTracker::Change::Type.values
  validates_inclusion_of :change_status, in: FileTracker::Change::Status.values

  before_validation :set_discovered_at, unless: :discovered_at?
  before_create :set_size, unless: :size?, if: :modification?

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

  private

  def accept_modification
    tracked_file.update(sha1: sha1, size: size, md5: nil, status: FileTracker::Status::OK)
    accepted!
    save!
  end

  def accept_deletion
    tracked_file.destroy # destroys all tracked changes related to tracked file!
  end

  def set_discovered_at
    self.discovered_at = DateTime.now
  end

end
