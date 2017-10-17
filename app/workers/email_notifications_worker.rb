class EmailNotificationsWorker
  include Sidekiq::Worker

  def perform
    User.joins(:notices, :settings).where(notices: { read_at: nil }, user_settings: { send_email_notifications: true }).distinct.find_each do |user|
      settings = user.settings
      notices = user.notices.unread.where("notices.created_at > ?", settings.last_email_sent)
      next unless notices.any?
      recent_notices = notices.where("notices.created_at > ?", 5.minutes.ago)
      next if recent_notices.any?
      settings.update(last_email_sent: DateTime.current)
      UserMailer.notifications(user, notices).deliver_later
    end
  end
end
