module FileTracker
  class Error < StandardError; end
  class FixityError < Error; end
  class MissingFileError < FixityError; end
  class ModifiedFileError < FixityError; end
end
