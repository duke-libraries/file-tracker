module HasStatus
  extend ActiveSupport::Concern

  FileTracker::Status.each do |key, value|
    define_method "#{key}?" do
      status == value
    end

    define_method "#{key}!" do
      self.status = value
    end
  end

  def status_label
    I18n.t "file_tracker.status.#{status}"
  end

end
