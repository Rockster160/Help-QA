Rails.application.configure do

  config.action_mailer.default_url_options = { host: 'localhost', port: 4357 }

  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  config.action_controller.perform_caching = true

  config.action_cable.url = "ws://localhost:4357/cable"

  config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # ActionMailer::Base.delivery_method = :smtp
  # ActionMailer::Base.smtp_settings = {
  #   address:              "email-smtp.us-east-1.amazonaws.com",
  #   port:                 587,
  #   user_name:            ENV["HELPQA_SMTP_USERNAME"],
  #   password:             ENV["HELPQA_SMTP_PASSWORD"],
  #   authentication:       :plain,
  #   enable_starttls_auto: true
  # }

  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true
  config.assets.quiet = true
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

end
