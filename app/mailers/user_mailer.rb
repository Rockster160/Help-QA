class UserMailer < ApplicationMailer
  def notifications(user)
    @user = user
    @notices = user.notices.unread.order(created_at: :desc)

    mail({
      to: user.email,
      subject: "Recent Notices from HelperNow"
    })
  end
end
