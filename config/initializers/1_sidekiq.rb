# Sidekiq 7 talks to Redis through redis-client and takes a URL rather than a
# host/port/db hash (Redis.current was removed in redis-rb 5).
#
# Sidekiq 7 also dropped redis-namespace, which is what used to keep this app's
# queues ("Helpqa_#{env}:sidekiq") from mixing with anything else on the same
# Redis. Without it a default db 0 is shared with every other project on this
# machine, so isolation now comes from a dedicated database number instead.
# cable.yml already claims 1 (production) and 2 (archive).
REDIS_DB_BY_ENV = { "development" => 3, "test" => 4, "archivedev" => 5 }.freeze

redis_url = ENV.fetch("REDIS_URL") do
  "redis://localhost:6379/#{REDIS_DB_BY_ENV.fetch(Rails.env, 6)}"
end

config = { url: redis_url }

Sidekiq.configure_server do |c|
  c.redis = config

  c.error_handlers << Proc.new do |exception, context_hash, _cfg|
    webhook = ENV["HELPQA_SLACK_WEBHOOK"]
    next if webhook.blank?

    ::Slack::Notifier.new(webhook, channel: "#help-qa", username: "Help-Bot")
      .ping("Sidekiq Error: >>> #{exception}: #{context_hash}", attachments: [])
  end
end

Sidekiq.configure_client { |c| c.redis = config }
