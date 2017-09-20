class ReadableValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    unless File.readable?(value)
      record.errors[attribute] << (options[:message] || "is not readable by the file-tracker application")
    end
  end

end
