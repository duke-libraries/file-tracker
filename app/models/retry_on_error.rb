class RetryOnError

  class << self
    attr_writer :config

    def config_file
      File.join(Rails.root, "config", "retry_on_error.yml")
    end

    def config
      @config ||= load_config
    end

    def load_config
      YAML.load_file(config_file) rescue {}
    end

    def wrap(&block)
      retries = 0
      begin
        block.call
      rescue Exception => e
        if handler = config[e.class.to_s]
          if retries < handler["retries"]
            retries += 1
            sleep handler["wait"]
            retry
          end
        end
        raise
      end
    end
  end

end
