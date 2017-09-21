class TrackedFile < ActiveRecord::Base
  include HasFixity
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

  def generate_fixity
    GenerateFixityJob.perform_later(self)
  end

  def check_fixity!
    check_fixity.tap do |result|
      self.fixity_checked_at = result.checked_at
      self.fixity_status = result.status
      save
    end
  end

  def check_fixity
    FixityCheck.call(self)
  end

end
