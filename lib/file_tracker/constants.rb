module FileTracker
  module Constants

    def values
      @values ||= constants(false).map { |c| const_get(c) }.sort
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
