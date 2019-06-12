class NotificationsWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)

    notices = user.notices.unread.where("created_at > ?", user.last_notified || DateTime.new)
    shouts = user.shouts.unread.where("created_at > ?", user.last_notified || DateTime.new)
    invites = user.invites.unread.where("created_at > ?", user.last_notified || DateTime.new)
    return if (notices + shouts + invites).none?
    user.update(last_notified: Time.current)

    UserMailer.notifications(user).deliver_now
  end
end
