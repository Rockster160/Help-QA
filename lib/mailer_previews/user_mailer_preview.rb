class UserMailerPreview < ActionMailer::Preview
  def notifications
    UserMailer.notifications(User.not_helpbot.first)
  end
end
