class Archive
  include ActiveModel::Model

  def self.track!(path)
    new(path: path).tap { |archive| archive.track! }
  end

  attr_accessor :path

  def to_s
    path
  end

  def track!
    dirs.each { |dir| TrackDirectoryJob.perform_later(dir) }
  end

  def dirs
    paths.lazy.map { |p| TrackedDirectory.find_or_create_by!(path: p) }
  end

  def paths
    children.select { |d| File.directory?(d) }
  end

  def children
    entries = if Dir.respond_to?(:children)
                Dir.children(path) # Ruby 2.4+
              else
                Dir.entries(path) - ['.', '..']
              end
    entries.map { |d| File.absolute_path(d, path) }
  end

end
