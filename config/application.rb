require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Helpqa
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Staged upgrade: the app came from Rails 5.0 defaults. 6.1 is the intermediate
    # step recommended by the upgrade guide; bump to 7.0 once the suite is green.
    config.load_defaults 6.1

    # app/workers is picked up automatically by Zeitwerk -- every app/* directory
    # is an autoload root, so it must not be added a second time.

    config.paperclip_defaults = {
      storage:           :s3,
      s3_region:         "us-east-2",
      s3_host_name:      "s3.us-east-2.amazonaws.com",
      preserve_files:    true,
      bucket:            "help-qa",
      path:              "#{Rails.env}/:class/:attachment/:id_partition/:style/:filename",
      access_key_id:     ENV["HELPQA_AWS_ID"],
      secret_access_key: ENV["HELPQA_AWS_ACCESS"]
    }

    config.after_initialize do
      Rails.cache.write("users_chatting", [])
      ActionCable.server.broadcast("chat", {ping: true})
    end
  end
end
