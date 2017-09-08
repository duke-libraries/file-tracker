class Archive
  include ActiveModel::Model

  def self.track!(path, async: false)
    new(path: path).tap do |archive|
      archive.track!(async: async)
    end
  end

  attr_accessor :path

  def to_s
    path
  end

  def track!(async: false)
    dirs.each do |dir|
      TrackedDirectory.track!(dir, async: async)
    end
  end

  def dirs
    @dirs ||= children.select { |d| File.directory?(d) }
  end

  def children
    entries = Dir.entries(path) - ['.', '..'] # Ruby 2.4 has Dir.children(path)
    entries.map { |d| File.absolute_path(d, path) }
  end

end
