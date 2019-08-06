require 'slack-notifier'
class SlackWorker
  include Sidekiq::Worker
  WEBHOOK_URL = ENV["PORTFOLIO_SLACK_HOOK"]

  # https://api.slack.com/docs/attachments

  def perform(message, channel='#helpqa', username='Help-Bot', icon_emoji=':helpbot:', attachments=[])
    ::Slack::Notifier.new(WEBHOOK_URL, channel: channel, username: username, attachments: attachments, icon_emoji: icon_emoji).ping(message)
  end

end
