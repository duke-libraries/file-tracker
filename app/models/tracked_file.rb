class TrackedFile < ActiveRecord::Base

  has_many :fixity_checks, dependent: :destroy

  scope :under, ->(path) { where("path LIKE ?", "#{path}/%") }
  scope :not_fixity_checked, -> { includes(:fixity_checks).where(fixity_checks: { id: nil }) }
  scope :fixity_checked,     -> { includes(:fixity_checks).where.not(fixity_checks: { id: nil }) }

  def self.fixity_check_due
    left_outer_joins(:fixity_checks).group('tracked_files.id').having("max(fixity_checks.checked_at) < ?", FixityCheck.due_date)
  end

  def fixity_check!
    FixityCheck.check!(self)
  end

  def last_fixity_check
    fixity_checks.order(checked_at: :desc).first
  end

  def digests
    @digests ||= Digests.new(path, md5, sha1)
  end

end
