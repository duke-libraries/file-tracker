class TrackedFile < ActiveRecord::Base
  include TrackedFileDisplay
  include TrackedFileAdmin

  validates :path, file_exists: true, readable: true, uniqueness: true
  before_create :set_size, if: "size.nil?"
  after_create :generate_fixity, unless: :has_fixity?

  def self.track!(*paths)
    paths.each { |path| find_or_create_by!(path: path) }
  end

  def self.under(path)
    return all if path.blank? || path == "/"
    value = File.realpath(path)
    where("path LIKE ?", "#{value}/%")
  end

  def to_s
    path
  end

  def has_fixity?
    fixity.complete?
  end

  def generate_fixity!
    update calculate_fixity.to_h
  end

  def generate_fixity
    GenerateFixityJob.perform_later(self)
  end

  def check_fixity!
    result = check_fixity
    self.fixity_checked_at = result.checked_at
    self.fixity_status = result.status
    save
    result.raise_error!
  end

  def check_fixity
    FixityCheckResult.call(self)
  end

  def fixity
    Fixity.new(md5, sha1)
  end

  def calculate_fixity
    self.class.calculate_fixity(path)
  end

  def set_size
    self.size = calculate_size
  end

  def calculate_size
    File.size(path)
  end

  def calculate_fixity
    Fixity.calculate(path)
  end

end
