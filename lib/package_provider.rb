require 'logger'

# Namespace that handles git operations for PackageProvider
module PackageProvider
  class << self
    # rubocop:disable TrivialAccessors
    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def logger=(l)
      @logger = l
    end
    # rubocop:enable TrivialAccessors
    def config
    end

    def root
      File.expand_path('../..', __FILE__)
    end
  end
end
