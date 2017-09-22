require 'slack-notifier'
class SlackWorker
  include Sidekiq::Worker
  WEBHOOK_URL = "https://hooks.slack.com/services/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"

  # https://api.slack.com/docs/attachments

  def perform(message, channel='#helpernow', username='Help-Bot', icon_emoji=':heavy_plus_sign:', attachments=[])
    ::Slack::Notifier.new(WEBHOOK_URL, channel: channel, username: username).ping(message, attachments: attachments)
  end 

end
