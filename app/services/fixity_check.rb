class FixityCheck
  include HasFixity

  attr_reader :tracked_file, :result
  attr_accessor :size, :sha1

  delegate :path, to: :tracked_file

  def self.call(tracked_file)
    new(tracked_file).check!
  end

  def initialize(tracked_file)
    @tracked_file = tracked_file
    @result = FixityCheckResult.new(path: tracked_file.path)
  end

  def check!
    start!
    begin
      check_size
      check_sha1
    rescue FileTracker::AlteredFileError => e
      result.altered!(e)
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
      finish!
    end
    result
  end

  def start!
    result.started_at = DateTime.now
  end

  def finish!
    result.finished_at = DateTime.now
    result.size = size
    result.sha1 = sha1
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
