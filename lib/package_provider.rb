module PackageProvider
  class << self
    def logger
    end

    def config
    end

    def root
      File.expand_path('../..', __FILE__)
    end
  end
end
