module FixityCheckResultDisplay
  include CommonDisplay

  def display_status
    I18n.t "file_tracker.fixity.status.#{status}"
  end

end
