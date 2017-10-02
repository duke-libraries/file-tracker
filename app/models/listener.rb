require 'listen'

class Listener

  class << self
    def pidfile
      File.join(Rails.root, "tmp", "pids", "file-tracker-listener.pid")
    end

    def pidfile?
      File.exist?(pidfile)
    end

    def pid
      if pidfile?
        File.read(pidfile).strip
      end
    end

    def pid=(process_id)
      File.open(pidfile, "w") { |f| f.write(process_id) }
    end

    def listener
      @listener ||= Listen.to(*paths, **options, &method(:track_changes))
    end

    def start
      return false if running?
      self.pid = fork do
        listener.start
        sleep
      end
      running?
    end

    def running?
      !!pid && system("ps", "-p", pid)
    end

    def stop
      return false if !running?
      begin
        Process.kill("TERM", pid)
        Process.wait(pid, Process::WNOHANG)
        $?.success?
      ensure
        cleanup
      end
    end

    def paths
      TrackedDirectory.pluck(:path)
    end

    def options
      {}
    end

    def track_changes(modified, added, removed)
      track_added(added)
      track_modified(modified)
      track_removed(removed)
    end

    def track_modified(paths)
      paths.each { |path| track_change(path, :modification) }
    end

    def track_added(paths)
      TrackedFile.track!(*paths)
    end

    def track_removed(paths)
      paths.each { |path| track_change(path, :deletion) }
    end

    def track_change(path, change_type)
      if tracked_file = TrackedFile.find_by(path: path)
        TrackedChange.create(tracked_file: tracked_file,
                             change_type: FileTracker::Change::Type.send(change_type))
      end
    end

    private

    def cleanup
      File.unlink(pidfile) if pidfile?
    end
  end

end
