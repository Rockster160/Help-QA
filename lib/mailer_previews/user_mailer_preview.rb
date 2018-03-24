class UserMailerPreview < ActionMailer::Preview
  def notifications
    UserMailer.notifications(User.not_helpbot.first, "Some generic message")
  end

  def historical_invite
    UserMailer.historical_invite("some@email.com")
  end
end
