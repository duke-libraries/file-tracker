class IndexDocumentIndexJob < IndexJob

  def self.perform(class_name, id)
    record = class_name.constantize.find(id)
    record.__elasticsearch__.index_document
  end

end
