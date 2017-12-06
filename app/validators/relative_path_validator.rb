class RelativePathValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    unless Pathname.new(value).relative?
      record.errors[attribute] << (options[:message] || "is not a relative path")
    end
  end

end
