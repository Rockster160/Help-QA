class EmailNotificationsWorker
  include Sidekiq::Worker

  def perform
    subs = Subscription.joins(post: :replies).where("replies.created_at > subscriptions.last_notified_at").distinct

    subs.each do |subscription|
      user = subscription.user
      settings = user.settings
      next if settings.send_reply_notifications?

      post = subscription.post
      notices = user.notices.subscription.where(notices: { read_at: nil }).where(notice_for_id: post.id)
      next if notices.none?

      recent_notices = notices.where("notices.created_at > ?", 5.minutes.ago)
      next if recent_notices.any?

      subscription.update(last_notified_at: DateTime.current)
      UserMailer.notifications(user, notices).deliver_later
    end
  end
end
