class UserMailer < ApplicationMailer
  def notifications(user)
    @user = user
    @grouped_notices = user.notices.unread.order(created_at: :desc).group_by do |notice|
      next notice.id unless notice.subscription?
      "sub: #{notice.notice_for_id}"
    end

    mail({
      to: user.email,
      subject: "Recent Notices from Help-QA"
    })
  end
end
