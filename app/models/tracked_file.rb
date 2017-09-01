class TrackedFile < ActiveRecord::Base

  include TrackedFileAdmin

  scope :under, ->(path) { where("path LIKE ?", "#{path}/%") }

  before_create :set_fixity

  def self.fixity_check_due
    where("fixity_checked_at < ?", FixityCheck.due_date)
  end

  def fixity_check!
    self.fixity_checked_at = DateTime.now
    self.fixity_status = fixity_check
    save!
  end
  alias_method :check_fixity!, :fixity_check!

  def fixity_check
    Fixity.check(fixity)
  end
  alias_method :check_fixity, :fixity_check

  def fixity
    @fixity ||= Fixity.new(path, md5, sha1, size)
  end

  def fixity_display_status
    Fixity::DISPLAY_STATUS[fixity_status]
  end

  def set_fixity
    self.md5  = fixity.md5  unless md5
    self.sha1 = fixity.sha1 unless sha1
    self.size = fixity.size unless size
  end

end
