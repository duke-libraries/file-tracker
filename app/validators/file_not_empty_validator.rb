class FileNotEmptyValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if File.zero?(value)
      record.errors[attribute] << "is an empty file"
    end
  end

end
