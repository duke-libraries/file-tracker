module FileTracker
  module Status

    OK         = 0
    MODIFIED   = 1
    MISSING    = 2
    ERROR      = 3

    def self.values
      @@value ||= constants(false).map { |c| const_get(c) }.sort
    end

    constants(false).each do |c|
      define_singleton_method c.to_s.downcase do
        const_get(c)
      end
    end

  end
end
