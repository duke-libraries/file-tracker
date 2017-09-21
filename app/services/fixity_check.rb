class FixityCheck

  attr_reader :tracked_file, :result

  class_attribute :save_result_on_status
  self.save_result_on_status = (1..3)

  def self.call(tracked_file)
    new(tracked_file).check!
  end

  def initialize(tracked_file)
    @tracked_file = tracked_file
    @result = FixityCheckResult.new(path: tracked_file.path)
  end

  def check!
    result.start!
    begin
      check_size
      check_fixity
    rescue FileTracker::AlteredFileError => e
      result.altered!
    rescue Errno::ENOENT => e # file does not exist
      result.missing!
    rescue Errno::EACCES => e # e.g., cannot read file
      result.error!(e)
    rescue Exception => e # some other issue
      result.error!(e)
      raise
    else
      result.ok!
    ensure
      result.finish!
      result.save! if save_result?
    end
    result
  end

  def save_result?
    save_result_on_status.include?(result.status)
  end

  def save_result!
    result.save!
  end

  def check_size
    result.set_size
    unless result.size == tracked_file.size
      raise FileTracker::AlteredFileError,
            "Expected size: #{tracked_file.size}; actual size: #{result.size}"
    end
  end

  def check_fixity
    result.set_fixity
    unless result.fixity == tracked_file.fixity
      raise FileTracker::AlteredFileError,
            "Expected: #{tracked_file.fixity}; actual: #{result.fixity}"
    end
  end

end
