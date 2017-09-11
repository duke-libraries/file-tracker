module TrackedFileDisplay
  include CommonDisplay

  def display_fixity_status
    case fixity_status
    when 0
      "OK"
    when 1
      "CHANGED"
    when 2
      "MISSING"
    else
      "NOT CHECKED"
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
