class UserMailer < ApplicationMailer
  def notifications(user, notices)
    @user = user
    @notices = notices

    mail({
      to: user.email,
      subject: "Recent Notices from HelperNow"
    })
  end
end
