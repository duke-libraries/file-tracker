class Hashdeep

  COLUMNS = %i( size md5 sha1 path ).freeze

  def self.hashes(path)
    new(path).to_enum
  end

  attr_reader :path

  def initialize(path)
    @path = path
  end

  def each
    calculate do |io|
      io.each do |line|
        if line =~ /^\d/
          yield line.chomp.split(/,/, 4) # size,md5,sha1,filename
        end
      end
    end
  end

  def calculate
    option = File.directory?(path) ? "-r" : "-f"
    command = [ "hashdeep", "-c", "md5,sha1", option, path ]
    IO.popen(command) do |io|
      io.flush
      yield io
    end
  end

end
