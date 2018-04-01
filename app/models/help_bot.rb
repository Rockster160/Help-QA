class HelpBot
  extend UrlHelper

  class << self
    def helpbot; $helpbot ||= User.by_username("HelpBot"); end

    def react_to_post(post)
      return if Rails.env.archive?
      return unless Tag.sounds_depressed?(post.body)

      reply_to_post(post, ApplicationController.render(partial: "replies/helpbot_message"))
    end

    def react_to_reply(reply)
    end

    def react_to_email(email)
      return unless email.from == "MAILER-DAEMON@amazonses.com"
      message = email.messages.first
      return unless message.present?
      bad_messages = [
        "An error occurred while trying to deliver the mail to the following recipients:",
        "Delivery has failed to these recipients or groups:"
      ]
      bad_email = message[/(#{bad_messages.join('|')})\s*\S*/].to_s[/\S+$/]
      return if bad_email.blank?
      email.update(subject: "(Failure to deliver) #{bad_email}")
      user = User.find_by("LOWER(email) = ?", bad_email.squish.downcase)
      return if user.nil?
      url = url_for(route_for(:account_settings_path))
      user.settings.update(send_email_notifications: false)
      return if helpbot.shouts.shouts_from.where(sent_to: user).any?
      shout_user(user, "Hi there!\n\nI just tried to send you an email, but was told it doesn't exist. Could you verify that you've typed your email correctly? You can view your email and change it by visiting this url:\n\n#{url}\n\nIf you don't want to receive email notifications, that's okay! It will be helpful to use a real email account so you can access your account if you forget your password. You can opt-out of all other emails by clicking \"Do not email me\" in your account settings on the same page you set your email.")
    end

    def reply_to_post(post, message)
      helpbot.replies.create(post: post, body: message)
    end

    def shout_user(user, message)
      helpbot.shouts_from.create(body: message, sent_to: user)
    end
  end
end
