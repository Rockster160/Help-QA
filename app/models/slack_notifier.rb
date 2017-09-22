class SlackNotifier

  def self.notify(message, channel: '#helpernow', username: 'Help-Bot', icon_emoji: ':heavy_plus_sign:', attachments: [])
    SlackWorker.perform_async(message, channel, username, icon_emoji, attachments)
  end

end
