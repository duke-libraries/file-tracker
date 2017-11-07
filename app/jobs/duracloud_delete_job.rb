class DuracloudDeleteJob < DuracloudJob

  def self.perform(*args)
    Duracloud::Content.delete(*args)
  end

end
