class SlackNotifier

  def self.notify(message, channel: '#helpqa', username: 'Help-Bot', icon_emoji: ':helpbot:', attachments: [])
    SlackWorker.perform_async(message, channel, username, icon_emoji, attachments)
  end

end
