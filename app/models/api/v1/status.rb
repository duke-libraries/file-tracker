module Api::V1
  class Status
    include ActiveModel::Model

    Meta = Struct.new(:version, :config)
    Data = Struct.new(:queues, :directories, :files)
    Queues = Struct.new(:info, :queues)
    FileInfo = Struct.new(:total, :size, :large)

    attr_reader :meta, :data

    def initialize
      @meta = Meta.new(FileTracker::VERSION, FileTracker.config)
      @data = Data.new(queues, directories, file_info)
    end

    def queues
      Queues.new(Resque.info.slice(:pending, :processed, :workers, :working, :failed),
                 Resque.queue_sizes)
    end

    def directories
      TrackedDirectory.all
    end

    def file_info
      size = TrackedFile.sum(:size)
      FileInfo.new(TrackedFile.count,
                   ActiveSupport::NumberHelper.number_to_human_size(size),
                   TrackedFile.large.count)
    end

  end
end
