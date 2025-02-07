require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Shike
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # I18n config
    config.load_defaults 5.0
    config.i18n.default_locale = :cn
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]

    # Time Zone config
    config.time_zone = 'Beijing'
    config.active_record.default_timezone = :local

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # specific slim as dafault template engine for generator
    config.generators do |g|
      g.template_engine = :slim
    end
  end
end
