class DeleteDocumentIndexJob < IndexJob

  def self.perform(class_name, id)
    klass = class_name.constantize
    client = Elasticsearch::Client.new
    client.delete index: klass.index_name, type: klass.document_type, id: id
  end

end
