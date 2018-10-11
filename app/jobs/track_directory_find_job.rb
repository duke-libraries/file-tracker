require 'find'

class TrackDirectoryFindJob < TrackDirectoryJob

  def perform(path)
    Find.find(path) do |subpath|
      begin
        if FileTest.file?(subpath)
          unless FileTest.symlink?(subpath) || path == subpath
            TrackFileJob.perform_later(subpath)
          end
        end
      rescue *(FileTracker.log_file_errors) => e
        logger.error(e)
      end
    end
  end

end
