Rails.application.configure do

  config.action_mailer.default_url_options = { host: 'localhost', port: 4358 }

  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  config.action_controller.perform_caching = true

  config.action_cable.url = "ws://localhost:4358/cable"

  config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true
  config.assets.quiet = true
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

end
