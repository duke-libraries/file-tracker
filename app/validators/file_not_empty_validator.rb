class FileNotEmptyValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    FileUtils.cd(record.tracked_directory.path) do
      if File.zero?(value)
        record.errors[attribute] << "is an empty file"
      end
    end
  end

end
