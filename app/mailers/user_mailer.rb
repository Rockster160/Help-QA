class UserMailer < ApplicationMailer
  include UrlHelper

  def notifications(user)
    @user = user
    @login_params = { auth: user.auth_token }

    notices = user.notices.unread.map { |notice| [notice.created_at, notice.groupable_identifier, notice] }
    shouts = user.shouts.unread.map { |shout| [shout.created_at, "shout-#{shout.sent_from_id}", shout] }
    invites = user.invites.unread.map { |invite| [invite.created_at, "invite-#{invite.groupable_identifier}", invite] }

    all_notifications = (notices + shouts + invites)
    all_notifications = all_notifications.sort_by { |timestamp, grouper, instance| -timestamp.to_i }
    all_notifications = all_notifications.each_with_object({}) do |notification, count_hash|
      timestamp, grouper, instance = notification
      count_hash[grouper] ||= [0, instance]
      count_hash[grouper][0] += 1
    end

    @notifications = all_notifications.values

    notification_mail = mail({
      to: user.email,
      subject: "We're missing you at Help-QA!"
    })
    notification_mail.perform_deliveries = false if @notifications.none?
    notification_mail
  end

  def confirmation_instructions(user)
    @user = user

    mail({
      to: user.unconfirmed_email || user.email,
      subject: "Confirmation Instructions",
      template_name: user.unconfirmed_email.present? ? 'reconfirmation_instructions' : 'confirmation_instructions'
    })
  end

  def historical_invite(email)
    mail({
      to: email,
      subject: "Help.com needs you!"
    })
  end

  def email(email, subject, body)
    mail({
      to: email,
      subject: subject,
      body: body
    })
  end
end

# ActionMailer::Base.mail(from: "\"Help-QA\" <contact@help-qa.com>", to: "rocco11nicholls+test@gmail.com", subject: "test", body: "test").deliver
