class FixityCheckResult < ActiveRecord::Base

  include FileTracker::Status
  include FixityCheckResultAdmin

  validates_presence_of :path
  validates_inclusion_of :status, in: FileTracker::Status.values, allow_nil: true

  def checked_at
    started_at
  end

  %w( ok modified missing error ).each do |stat|
    value = FileTracker::Status.send(stat)

    define_method "#{stat}?" do
      status == value
    end

    define_method "#{stat}!" do |message = nil|
      self.status = value
      self.message = message if message
    end
  end

end
