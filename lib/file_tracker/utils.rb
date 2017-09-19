module FileTracker
  module Utils

    mattr_accessor :large_file_threshhold do
      ENV.fetch("LARGE_FILE_THRESHHOLD", 10**9).to_i
    end

    def large_file?(path)
      File.size(path) > large_file_threshhold
    end

    extend self

  end
end
