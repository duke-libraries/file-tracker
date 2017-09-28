class TrackedChange < ActiveRecord::Base

  include FileTracker::Change::Type
  include FileTracker::Change::Status
  include TrackedChangeAdmin

  validates_presence_of :path, :discovered_at
  validates_inclusion_of :change_type, in: [ MODIFICATION, DELETION ]
  validates_inclusion_of :change_status, in: [ ACCEPTED, REJECTED ], allow_nil: true

  scope :pending, ->{ where(change_status: nil) }

  def tracked_file
    @tracked_file ||= TrackedFile.find_by!(path: path)
  end

  def accept!
    case change_type
    when MODIFICATION
      tracked_file.update(sha1: sha1, size: size, md5: nil, fixity_status: FileTracker::Status::OK)
    when DELETION
      tracked_file.destroy
    end
    accepted!
    save!
  end

  def reject!
    rejected!
    save!
  end

  %w( pending accepted rejected ).each do |status|
    value = const_get(status.upcase)

    define_method "#{status}?" do
      change_status == value
    end

    define_method "#{status}!" do
      self.change_status = value
    end
  end

end
