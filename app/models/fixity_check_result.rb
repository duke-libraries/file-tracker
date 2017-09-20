class FixityCheckResult < ActiveRecord::Base

  OK      = 0
  CHANGED = 1
  MISSING = 2
  ERROR   = 3

  validates_presence_of :path
  validates_inclusion_of :status, in: (0..3)

  def self.call(tracked_file)
    FixityCheckResult.new(path: tracked_file.path).tap do |result|
      begin
        result.size = tracked_file.calculate_size
        tracked_file.size == result.size ? result.ok! : result.altered!
        if result.ok?
          result.fixity = tracked_file.calculate_fixity
          result.altered! if tracked_file.fixity != result.fixity
        end
      rescue Errno::ENOENT => e
        result.missing!
      rescue Errno::EACCES => e
        result.error!(e)
      end
      result.save unless result.ok?
    end
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
    status == CHANGED
  end

  def altered!
    self.status = CHANGED
  end

  def error?
    status == ERROR
  end

  def error!(exc)
    self.status = ERROR
    self.error = exc.inspect
  end
end
