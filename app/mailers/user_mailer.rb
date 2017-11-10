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
      to: user.email,
      subject: "Confirmation Instructions",
      template_name: (user.pending_reconfirmation? && !user.verified?) ? 'reconfirmation_instructions' : 'confirmation_instructions'
    })
  end
end

# ActionMailer::Base.mail(from: "\"Help-QA\" <helpqacontact@gmail.com>", to: "rocco11nicholls+test@gmail.com", subject: "test", body: "test").deliver
