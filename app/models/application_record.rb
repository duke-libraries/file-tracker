class ApplicationRecord < ActiveRecord::Base

  self.abstract_class = true

  def self.csv_headers
    attribute_names
  end

  def self.to_csv(options = {})
    all.to_csv(options)
  end

  def to_csv(options = {})
    attributes
  end

end

ActiveRecord::Relation.class_eval do
  def to_csv(options = {})
    CSV.generate(headers: csv_headers, write_headers: true) do |csv|
      each do |record|
        csv << record.to_csv
      end
    end
  end
end
