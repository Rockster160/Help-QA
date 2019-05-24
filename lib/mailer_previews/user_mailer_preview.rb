class UserMailerPreview < ActionMailer::Preview
  def notifications
    UserMailer.notifications(User.find_by(id: 5) || User.not_helpbot.first)
  end

  def historical_invite
    UserMailer.historical_invite("some@email.com")
  end
end
