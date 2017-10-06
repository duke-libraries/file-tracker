module HasStatus
  extend ActiveSupport::Concern

  included do
    FileTracker::Status.each do |key, value|
      scope key, ->{ where(status: value) }
    end

    scope :not_ok, ->{ where.not(status: FileTracker::Status::OK) }
  end

  FileTracker::Status.each do |key, value|
    define_method "#{key}?" do
      status == value
    end

    define_method "#{key}!" do
      self.status = value
    end
  end

end
