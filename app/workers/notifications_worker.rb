class NotificationsWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)

    notices = user.notices.unread
    shouts = user.shouts.unread
    invites = user.invites.unread
    return if (notices + shouts + invites).none?

    UserMailer.notifications(user).deliver_now
  end
end
