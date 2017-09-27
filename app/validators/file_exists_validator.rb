class FileExistsValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    unless File.file?(value)
      record.errors[attribute] << (options[:message] || "does not exist or is not a file")
    end
  end

end
