class HelpBot
  extend UrlHelper

  class << self
    def helpbot; $helpbot ||= User.by_username("HelpBot") || create_helpbot; end

    def create_helpbot
      User.create({
        email: "rocco11nicholls+helpbot@gmail.com",
        password: (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(20),
        created_at: 1.year.ago,
        remember_created_at: 1.year.ago,
        username: "HelpBot",
        confirmed_at: 1.year.ago,
        verified_at: 1.year.ago,
        date_of_birth: Date.strptime("07/22/1993", "%m/%d/%Y"),
        avatar_url: ActionController::Base.helpers.asset_path("HelpBot.jpg"),
        archived: true
      })
    end

    def react_to_post(post)
      return if Rails.env.archive?
      # Notify me
      author = post.author
      author_path = url_for(Rails.application.routes.url_helpers.user_path(author))
      post_path = url_for(Rails.application.routes.url_helpers.post_path(post))

      slack_message = "Author: #{'un' unless author.verified?}verified user <@#{author_path}|#{author.username}>\nPost: <#{post_path}|#{post.title}>"

      attachment = {
        fallback: slack_message,
        title: "New post has been submitted",
        text: slack_message,
        color: "#0F6FFF"
      }
      SlackNotifier.notify("", attachments: [attachment])
      # ^^
      return unless Tag.sounds_depressed?(post.body)

      reply_to_post(post, ApplicationController.render(partial: "replies/helpbot_message"))
    end

    def react_to_reply(reply)
    end

    def react_to_email(email)
      check_failed_to_deliver(email)
    end

    def reply_to_post(post, message)
      helpbot.replies.create(post: post, body: message)
    end

    def shout_user(user, message)
      helpbot.shouts_from.create(body: message, sent_to: user)
    end

    def check_failed_to_deliver(email)
      failed_user = email.failed_to_deliver_to_user
      return if failed_user.nil?
      email.update(subject: "(Failure to deliver)")
      url = url_for(route_for(:account_settings_path))
      failed_user.settings.update(send_email_notifications: false)
      return if helpbot.shouts_from.where(sent_to: failed_user).any? # This should check only the bad emails - maybe just add a boolean to see if that email has been attempted already?
      shout_user(failed_user, "Hi there!\n\nI just tried to send you an email, but was told it doesn't exist. Could you verify that you've typed your email correctly? You can view your email and change it by visiting this url:\n\n#{url}\n\nIf you don't want to receive email notifications, that's okay! It will be helpful to use a real email account so you can access your account if you forget your password. You can opt-out of all other emails by clicking \"Do not email me\" in your account settings on the same page you set your email.")
      if failed_user.replies.one?
        first_reply = failed_user.replies.first
        if first_reply.sounds_like_spam?
          first_reply.ignore_sherlock = true
          first_reply.destroy
        end
      end
    end
  end
end
