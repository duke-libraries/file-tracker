module LargeFileJob
  extend ActiveSupport::Concern

  included do
    class_attribute :large_file_queue
  end

  module ClassMethods
    def dequeue_all
      super + dequeue_large_files
    end

    def dequeue_large_files
      Resque::Job.destroy(large_file_queue, self)
    end

    def queue_for_tracked_file(tracked_file)
      if tracked_file.large?
        large_file_queue
      else
        queue
      end
    end
  end
end
