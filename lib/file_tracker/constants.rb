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
        constants(false).each do |c|
          define_singleton_method c.to_s.downcase do
            const_get(c)
          end
        end
      end
    end

  end
end
