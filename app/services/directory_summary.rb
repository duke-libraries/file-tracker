require 'csv'
require 'pathname'

class DirectorySummary
  include ActiveModel::Model

  HEADERS = %w( path total ) + FileTracker::Status.keys

  attr_accessor :path

  validates :path, directory_exists: true

  # @return [Array] array of hashes
  def data
    @data ||= run.map do |path, stats|
      stats.merge("path"=>path, "total"=>stats.values.reduce(:+))
    end
  end

  def json
    data.to_json
  end

  def csv
    CSV.generate(headers: HEADERS, write_headers: true) do |csv|
      data.each { |row| csv << row }
    end
  end

  def reset
    @data = nil
  end

  def run
    validate!
    dirpath = Pathname.new(path)
    Hash.new.tap do |memo|
      TrackedFile.under(path).each do |file|
        filepath = Pathname.new(file.path)
        relpath = filepath.relative_path_from(dirpath)
        key = relpath.to_s.split(File::SEPARATOR, 2).first
        status_key = FileTracker::Status.key(file.status)
        memo[key] ||= Hash[FileTracker::Status.keys.product([0])]
        memo[key][status_key] += 1
      end
    end
  end

end
