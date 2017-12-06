class UpdateDocumentIndexJob < IndexJob

  def self.perform(class_name, id)
    record = class_name.constantize.find(id)
    record.__elasticsearch__.update_document
  end

end
