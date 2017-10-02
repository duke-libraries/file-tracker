class TrackedChange < ActiveRecord::Base

  include FileTracker::Change
  include HasFixity
  include TrackedChangeAdmin

  belongs_to :tracked_file

  delegate :path, to: :tracked_file

  validates_presence_of :tracked_file, :discovered_at
  validates_inclusion_of :change_type, in: FileTracker::Change::Type.values
  validates_inclusion_of :change_status, in: FileTracker::Change::Status.values, allow_nil: true

  before_validation :set_discovered_at, unless: :discovered_at
  before_create :set_size, unless: :size, if: :modification?

  scope :pending, ->{ where(change_status: nil) }

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

  %w( modification deletion ).each do |type|
    value = const_get(type.upcase)

    define_method "#{type}?" do
      change_type == value
    end

    define_method "#{type}!" do
      self.change_type = value
    end
  end

  %w( accepted rejected ).each do |status|
    value = const_get(status.upcase)

    define_method "#{status}?" do
      change_status == value
    end

    define_method "#{status}!" do
      self.change_status = value
    end
  end

  private

  def accept_modification
    tracked_file.update(sha1: sha1, size: size, md5: nil, fixity_status: FileTracker::Status::OK)
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
