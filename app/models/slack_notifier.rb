class SlackNotifier

  def self.notify(message="", channel: '#helpqa', username: 'Help-Bot', icon_emoji: ':helpbot:', attachments: [])
    # https://api.slack.com/docs/message-attachments
    # attachment = {
    #   fallback: "Required plain-text summary of the attachment.",
    #   color: "#2eb886", # Can also be [:good, :warning, :danger]
    #   pretext: "Optional text that appears above the attachment block",
    #   author_name: "Bobby Tables",
    #   author_link: "http://flickr.com/bobby/",
    #   author_icon: "http://flickr.com/icons/bobby.jpg",
    #   title: "Slack API Documentation",
    #   title_link: "https://api.slack.com/",
    #   text: "Optional text that appears within the attachment",
    #   fields: [
    #     {
    #       title: "Priority",
    #       value: "High",
    #       short: false
    #     }
    #   ],
    #   image_url: "http://my-website.com/path/to/image.jpg",
    #   thumb_url: "http://example.com/path/to/thumb.png",
    #   footer: "Slack API",
    #   footer_icon: "https://platform.slack-edge.com/img/default_application_icon.png",
    #   ts: 123456789 # timestamp in seconds
    # }
    # Sidekiq 7 enables strict_args! by default and rejects Symbols, which the
    # attachment hashes above are full of (`color: :warning`, symbol keys).
    # as_json renders them as the JSON-native types the job is serialized to
    # anyway, so the worker sees exactly what it saw before.
    SlackWorker.perform_async(message.to_s, channel.to_s, username.to_s, icon_emoji.to_s, attachments.as_json)
  end

end
