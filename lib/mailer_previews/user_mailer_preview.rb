class UserMailerPreview < ActionMailer::Preview
  def notifications
    UserMailer.notifications(User.first, Notice.last(10))
  end
end
