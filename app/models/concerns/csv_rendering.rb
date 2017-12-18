module CSVRendering
  extend ActiveSupport::Concern

  module ClassMethods
    def to_csv(options = {})
      CSV.generate(headers: csv_headers, write_headers: true) do |csv|
        all.each do |record|
          csv << record.to_csv
        end
      end
    end

    def csv_headers
      attribute_names
    end
  end

  def to_csv(options = {})
    attributes
  end

end
