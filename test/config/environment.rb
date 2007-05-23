RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  # We want no logging!
  logger = Object.new
  class << logger
    def method_missing(*args, &block)
      self
    end
  end
  config.logger = logger
end
