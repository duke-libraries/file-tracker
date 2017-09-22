class FixityCheckResult < ActiveRecord::Base

  include FileTracker::Status
  # include HasFixity
  include FixityCheckResultDisplay
  include FixityCheckResultAdmin

  validates_presence_of :path
  validates_inclusion_of :status, in: (0..3)

  def checked_at
    started_at
  end

  def start!
    self.started_at = DateTime.now
  end

  def finish!
    self.finished_at = DateTime.now
  end

  def ok?
    status == OK
  end

  def ok!
    self.status = OK
  end

  def missing?
    status == MISSING
  end

  def missing!
    self.status = MISSING
  end

  def altered?
    status == ALTERED
  end

  def altered!(exc = nil)
    self.status = ALTERED
    self.message = exc.inspect if exc
  end

  def error?
    status == ERROR
  end

  def error!(exc)
    self.status = ERROR
    self.message = exc.inspect
  end

end
