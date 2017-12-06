class AbsolutePathValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    unless Pathname.new(value).absolute?
      record.errors[attribute] << (options[:message] || "is not an absolute path")
    end
  end

end
