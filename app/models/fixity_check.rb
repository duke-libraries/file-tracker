class FixityCheck
  include ActiveModel::Model
  include HasFixity
  include HasStatus

  attr_accessor :tracked_file, :status, :size, :sha1, :started_at, :finished_at

  define_model_callbacks :execute
  before_execute { self.started_at = DateTime.now }
  after_execute { self.finished_at = DateTime.now }

  delegate :path, to: :tracked_file

  def self.call(tracked_file, **opts)
    new(tracked_file: tracked_file).tap do |fixity_check|
      fixity_check.execute(**opts)
    end
  end

  def execute(**opts)
    run_callbacks :execute do
      check(**opts)
    end
  end

  def check(**opts)
    begin
      check_size
      check_sha1 unless opts[:only_size]
    rescue FileTracker::ModifiedFileError => e
      modified!
    rescue Errno::ENOENT => e # file does not exist
      missing!
    rescue Errno::EACCES => e # permissions issue
      error!
    else
      ok!
    end
  end

  def check_size
    set_size
    unless size == tracked_file.size
      raise FileTracker::ModifiedFileError,
            I18n.t("file_tracker.error.modification.size",
                   expected: tracked_file.size,
                   actual: size)
    end
  end

  def check_sha1
    set_sha1
    unless sha1 == tracked_file.sha1
      raise FileTracker::ModifiedFileError,
            I18n.t("file_tracker.error.modification.sha1",
                   expected: tracked_file.sha1,
                   actual: sha1)
    end
  end

end
