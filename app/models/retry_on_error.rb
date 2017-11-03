class RetryOnError
  include ActiveModel::Model

  class_attribute :attempts, :wait
  self.attempts = 3
  self.wait = 5

  attr_accessor :exceptions

  validates_presence_of :exceptions
  validates_numericality_of :attempts, only_integer: true, greater_than: 0
  validates_numericality_of :wait, greater_than_or_equal_to: 0

  def self.wrap(exceptions, **options, &block)
    wrapper = new(options.merge(exceptions: exceptions))
    wrapper.wrap(&block)
  end

  def wrap(&block)
    validate!
    retries = 0
    begin
      block.call
    rescue *exceptions => e
      if retries < attempts
        retries += 1
        sleep wait
        retry
      end
      raise
    end
  end

end
