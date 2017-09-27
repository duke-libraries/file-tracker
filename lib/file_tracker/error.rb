module FileTracker
  class Error < StandardError; end
  class FixityError < Error; end
  class MissingFileError < FixityError; end
  class AlteredFileError < FixityError; end
end
