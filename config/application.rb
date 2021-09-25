require_relative 'boot'

require "rails"
# Pick the frameworks you want:
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
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Api2
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    Comff.load_global(File.read(File.join(Rails.root, "config/conf.#{Rails.env}.yml")))

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origin_url = URI.parse(Comff.get_str!('app.webapp_base_url'))

        if Rails.env.production?
          origins origin_url.host
        else
          origins "#{origin_url.host}:#{origin_url.port}"
        end

        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :delete, :options],
          credentials: true
      end
    end

    config.autoload_paths << Rails.root.join("lib")

    # rack-cache
    # config.action_dispatch.rack_cache = {
    #    verbose:     true,
    #    metastore:   'file:/var/cache/rack/meta',
    #    entitystore: 'file:/var/cache/rack/body'
    # }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
