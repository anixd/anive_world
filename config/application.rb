require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AniveWorld
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    ### Delete or comment after debug!
    # Rails.autoloaders.log!

    config.autoload_paths << Rails.root.join("app/services")
    config.autoload_paths << Rails.root.join("lib")

    config.autoload_paths += %W[
      #{config.root}/app/models/words
      #{config.root}/app/models/content_entries
    ]

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.eager_load_paths += %W[
      #{config.root}/app/services
      #{config.root}/lib
      #{config.root}/app/models/words
      #{config.root}/app/models/content_entries
    ]

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
