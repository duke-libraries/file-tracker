class QueueManager

  def self.pidfile
    File.join(Rails.root, "tmp", "pids", "resque-pool.pid")
  end

  def self.pid
    File.read(pidfile) rescue nil
  end

  def self.command
    [ "resque-pool", "-d", "-E", Rails.env, "--term-graceful" ]
  end

  def self.start
    if running?
      false
    else
      system(*command)
    end
  end

  def self.stop
    interrupt("-TERM")
  end

  def self.restart
    if stop
      while running?
        sleep 1
      end
      start
    else
      false
    end
  end

  def self.reload
    interrupt("-HUP")
  end

  def self.running?
    # system("pgrep", "-f", "resque-pool")
    # system("pgrep", "-F", pidfile)
    !!pid && system("ps", "-p", pid)
  end

  def self.interrupt(signal)
    if running?
      system("kill", signal, pid)
    else
      false
    end
  end

end
