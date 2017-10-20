class GenerateDigestJob < ApplicationJob
  include LargeFileJob

  self.queue = :digest
  self.large_file_queue = :digest_large

  def self.perform(tracked_file_id, digest)
    tracked_file = TrackedFile.find(tracked_file_id)
    tracked_file.set_digest!(digest) if tracked_file.generate_digest?(digest)
  end

end
