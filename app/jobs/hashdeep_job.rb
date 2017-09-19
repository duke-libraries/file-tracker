class HashdeepJob < ApplicationJob

  queue_as :hashdeep

  def perform(work_dir, files)
    data = []
    command = [ "hashdeep", "-s", "-c", "md5,sha1" ] + files
    IO.popen(command, chdir: work_dir) do |io|
      io.each do |line|
        next unless line =~ /^\d/ # skip hashdeep header
        size, md5, sha1, path = line.chomp.split(/,/, 4)
        data << { path: path, size: size.to_i, md5: md5, sha1: sha1 }
      end
    end
    TrackedFile.import(data)
  end

end
