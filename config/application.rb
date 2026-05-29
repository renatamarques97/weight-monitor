require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"

Bundler.require(*Rails.groups)

module WeightMonitor
  class Application < Rails::Application
    config.load_defaults 8.0
    config.active_support.to_time_preserves_timezone = :zone

    config.autoload_lib(ignore: %w[assets tasks])

    config.autoload_paths << Rails.root.join("app/services")
    config.eager_load_paths << Rails.root.join("app/services")

    config.generators.system_tests = nil
  end
end
