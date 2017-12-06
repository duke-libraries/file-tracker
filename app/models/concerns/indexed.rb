require 'elasticsearch/model'

module Indexed
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_create_commit :add_to_index
    after_update_commit :update_index
    after_destroy_commit :remove_from_index
  end

  def add_to_index
    Resque.enqueue(IndexDocumentIndexJob, self.class.to_s, id)
  end

  def update_index
    Resque.enqueue(UpdateDocumentIndexJob, self.class.to_s, id)
  end

  def remove_from_index
    Resque.enqueue(DeleteDocumentIndexJob, self.class.to_s, id)
  end

end
