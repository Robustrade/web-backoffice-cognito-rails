require_relative 'boot'

# require 'rails/all'
# active_record is what we're not going to use it, so add it to comment in case
# at some point we enable it back again
# require "active_record/railtie"

# This is not loaded in rails/all but inside active_record so add it if
# you want your models work as expected
# require 'active_model/railtie'
# And now the rest
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'active_job/railtie'
require 'action_cable/engine'
require 'rails/test_unit/railtie'

# We are using activemodel's validations in one of a service object.
require 'active_model'

# All these depend on active_record, so they should be excluded also
# require "action_text/engine" # Only for Rails >= 6.0
# require "action_mailbox/engine" # Only for Rails >= 6.0
# require "active_storage/engine" # Only for Rails >= 5.2

require 'factory_bot_rails'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WebBackofficeRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

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
  end
end
