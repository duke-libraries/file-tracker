module TrackedFileDisplay
  include CommonDisplay

  def display_fixity_status
    if fixity_status
      I18n.t "file_tracker.fixity.status.#{fixity_status}"
    else
      I18n.t "file_tracker.fixity.status.not_checked"
    end
  end

  def display_fixity
    value = display_fixity_status
    if fixity_checked_at
      value = value + " (as of #{fixity_checked_at})"
    end
    value
  end

end
