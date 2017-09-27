class DirectoryExistsValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    unless File.directory?(value)
      record.errors[attribute] << (options[:message] || "does not exist or is not a directory")
    end
  end

end
