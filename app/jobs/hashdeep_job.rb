class HashdeepJob < ApplicationJob

  queue_as :hashdeep

  def perform(dir)
    data = []
    files = ( Dir.entries(dir) - ['.', '..'] ).select { |f| File.file?(File.absolute_path(f, dir)) }
    hashdeep = %w( hashdeep -s -c md5,sha1 ) + files

    IO.popen(hashdeep, chdir: dir) do |io|
      io.each do |line|
        next unless line =~ /^\d/ # skip hashdeep header
        size, md5, sha1, path = line.chomp.split(/,/, 4)
        data << { path: path, size: size.to_i, md5: md5, sha1: sha1 }
      end
    end

    TrackedFile.import(data) if data.present?
  end

end
