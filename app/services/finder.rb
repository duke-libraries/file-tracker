module Finder

  def self.find(path)
    IO.popen(["find", path, "-type", "f"]) do |io|
      io.flush
      yield io
    end
  end

end
