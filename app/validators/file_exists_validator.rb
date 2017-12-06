class FileExistsValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    FileUtils.cd(record.tracked_directory.path) do
      if File.file?(value)
        if File.symlink?(value)
          record.errors[attribute] << "cannot be a symbolic link"
        end
      else
        record.errors[attribute] << "does not exist or is not a file"
      end
    end
  end

end
