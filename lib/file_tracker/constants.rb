module FileTracker
  module Constants

    delegate :keys, :values, :each, to: :to_h

    def to_h
      @hash ||= constants(false).each_with_object({}) do |c, memo|
        memo[c.to_s.downcase] = const_get(c)
      end
    end

    def self.extended(base)
      base.module_eval do
        # creates a class method in the extended module
        # for each constant key.
        each do |key, value|
          define_singleton_method(key) { value }
        end
      end
    end

  end
end
