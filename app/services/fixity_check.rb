class FixityCheck

  include HasFixity

  attr_reader :tracked_file, :result
  attr_accessor :size, :sha1

  delegate :path, to: :tracked_file

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
      check_sha1
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
      result.size = size
      result.sha1 = sha1
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
    set_size
    unless size == tracked_file.size
      raise FileTracker::AlteredFileError,
            "Expected size: #{tracked_file.size}; actual size: #{size}"
    end
  end

  def check_sha1
    set_sha1
    unless sha1 == tracked_file.sha1
      raise FileTracker::AlteredFileError,
            "Expected SHA1 {#{tracked_file.sha1}}; actual SHA1 {#{sha1}}"
    end
  end

end
