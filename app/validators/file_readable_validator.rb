class FileReadableValidator < ReadableValidator

  def validate_each(record, attribute, value)
    FileUtils.cd(record.tracked_directory.path) { super }
  end

end
