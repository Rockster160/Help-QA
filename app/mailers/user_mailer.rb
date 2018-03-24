class UserMailer < ApplicationMailer
  include UrlHelper

  def notifications(user, message)
    @user = user
    @message = add_params_to_urls_in_message(message, auth: user.auth_token)

    mail({
      to: user.email,
      subject: "We're missing you at Help-QA!"
    })
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
end

# ActionMailer::Base.mail(from: "\"Help-QA\" <helpqacontact@gmail.com>", to: "rocco11nicholls+test@gmail.com", subject: "test", body: "test").deliver
