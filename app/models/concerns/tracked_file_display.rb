module TrackedFileDisplay

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

  def display_size
    human_size = ActiveSupport::NumberHelper.number_to_human_size(size)
    "#{human_size} (#{size} bytes)"
  end

end
