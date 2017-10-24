require 'duracloud'

class DuracloudCheck
  include ActiveModel::Model

  NOT_CHECKED    = -1
  REPLICATED     = 0
  CONFLICT       = 1
  NOT_REPLICATED = 2

  delegate :tracked_directory, :md5, to: :tracked_file

  attr_accessor :tracked_file, :status, :checked_at

  define_model_callbacks :check

  before_check :set_checked_at
  after_check :update_tracked_file

  def self.call(tracked_file)
    new(tracked_file: tracked_file).tap do |duracloud_check|
      duracloud_check.check!
    end
  end

  def check!
    run_callbacks(:check) do
      self.status = check
    end
  end

  def check
    if Duracloud::Content.exist?(space_id: space_id, content_id: content_id, md5: md5)
      REPLICATED
    else
      NOT_REPLICATED
    end
  rescue Duracloud::MessageDigestError => e
    CONFLICT
  end

  def set_checked_at
    self.checked_at = DateTime.now
  end

  def update_tracked_file
    tracked_file.update(duracloud_status: status, duracloud_checked_at: checked_at)
  end

  def space_id
    tracked_directory.duracloud_space
  end

  def content_id
    path = tracked_directory.path + "/"
    tracked_file.path.sub(path, "")
  end

end
