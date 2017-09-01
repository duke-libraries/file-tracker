require 'digest'

class FixityCheck < ActiveRecord::Base

  belongs_to :tracked_file

  OK      = 0
  CHANGED = 1
  MISSING = 2

  class_attribute :days_per_cycle
  self.days_per_cycle = 60

  def self.due_date
    DateTime.now - days_per_cycle.days
  end

  def self.check!(tracked_file)
    new(tracked_file: tracked_file).check!
  end

  def check!
    self.checked_at = DateTime.now
    self.outcome = check
    save!
  end

  def check
    changed? ? CHANGED : OK
  rescue Errno::ENOENT => e
    MISSING
  end

  def path
    tracked_file.path
  end

  def changed?
    size_changed? || digest_changed?
  end

  def size
    File.size(path)
  end

  def size_changed?
    size != tracked_file.size
  end

  def digests
    @digests ||= Digests.new(path)
  end

  def digest_changed?
    digests != tracked_file.digests
  end

end
