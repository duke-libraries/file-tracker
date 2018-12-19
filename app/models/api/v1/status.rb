module Api::V1
  class Status
    include ActiveModel::Model

    RESQUE_INFO_KEYS = %i(pending processed workers working failed)

    Meta = Struct.new(:version, :config)
    Data = Struct.new(:queues, :directories, :files)
    Queues = Struct.new(:info, :queue_sizes)
    FileInfo = Struct.new(:count, :total_size, :large_files)

    attr_reader :meta, :data

    def initialize
      @meta = Meta.new(FileTracker::VERSION, FileTracker.config)
      @data = Data.new(queues, directories, file_info)
    end

    def queues
      Queues.new(Resque.info.slice(*RESQUE_INFO_KEYS),
                 Resque.queue_sizes)
    end

    def directories
      TrackedDirectory.all
    end

    def file_info
      FileInfo.new(TrackedFile.count,
                   TrackedFile.sum(:size),
                   TrackedFile.large.count)
    end

  end
end
