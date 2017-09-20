module FileTracker
  class Error < StandardError; end
  class FixityError < Error; end
  class FileMissingError < FixityError; end
  class FileChangedError < FixityError; end
end
