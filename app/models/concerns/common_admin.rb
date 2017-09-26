module CommonAdmin

  SHORT_DATE_FORMAT = "%F"
  LONG_DATE_FORMAT = "%F %T %Z"

  def pretty_status
    pretty_value { I18n.t("file_tracker.status.#{value || 'not_checked'}") }
  end

  def pretty_size
    pretty_value { ActiveSupport::NumberHelper.number_to_human_size(value) }
  end

  def short_date_format
    strftime_format SHORT_DATE_FORMAT
  end

  def long_date_format
    strftime_format LONG_DATE_FORMAT
  end

end
