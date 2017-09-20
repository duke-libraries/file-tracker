class FixityCheckResult < ActiveRecord::Base

  OK      = 0
  ALTERED = 1
  MISSING = 2
  ERROR   = 3

  class_attribute :save_status
  self.save_status = (1..3)

  validates_presence_of :path
  validates_inclusion_of :status, in: (0..3)

  def self.call(tracked_file)
    FixityCheckResult.new(path: tracked_file.path, started_at: DateTime.now).tap do |result|
      begin
        result.size = tracked_file.calculate_size
        tracked_file.size == result.size ? result.ok! : result.altered!
        if result.ok?
          result.fixity = tracked_file.calculate_fixity
          result.altered! if tracked_file.fixity != result.fixity
        end
      rescue Errno::ENOENT => e # file does not exist
        result.missing!
      rescue Errno::EACCES => e # e.g., cannot read file
        result.error!(e)
      end
      result.finished_at = DateTime.now
      result.save if result.save?
    end
  end

  def checked_at
    started_at
  end

  def save?
    save_status.include?(status)
  end

  def fixity
    Fixity.new(md5, sha1)
  end

  def fixity=(fxty)
    self.md5 = fxty.md5
    self.sha1 = fxty.sha1
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

  def altered!
    self.status = ALTERED
  end

  def error?
    status == ERROR
  end

  def error!(exc)
    self.status = ERROR
    self.error = exc.inspect
  end

  def raise_error!
    case result.status
    when ALTERED
      raise FileTracker::AlteredFileError, result.inspect
    when MISSING
      raise FileTracker::MissingFileError, result.inspect
    when ERROR
      raise FileTracker::FixityError, result.inspect
    end
  end

end
