require 'tempfile'

class NewFiles

  def self.hashes(path)
    new(path).hashes
  end

  attr_reader :path

  def initialize(path)
    @path = path
  end

  def hashes
    comm do |comm_path|
      Hashdeep.hashes(comm_path)
    end
  end

  def comm
    Tempfile.open("comm-") do |comm_tmp|
      find do |find_tmp|
        tracked do |tracked_tmp|
          system("comm", "-23", find_tmp, tracked_tmp, out: comm_tmp)
          comm_tmp.close
        end
      end
      yield comm_tmp.path
    end
  end

  def sort(input, output)
    system("sort", in: input, out: output)
  end

  def find
    Tempfile.open("find-") do |f|
      Finder.find(path) { |io| sort(io, f) }
      f.close
      yield f.path
    end
  end

  def tracked_paths
    TrackedFile.under(path).pluck(:path)
  end

  def tracked
    Tempfile.open("tracked-") do |f|
      IO.pipe do |r, w|
        w.puts tracked_paths
        w.close
        sort(r, f)
      end
      f.close
      yield f.path
    end
  end

end
