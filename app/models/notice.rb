# == Schema Information
#
# Table name: notices
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  notice_type   :integer
#  title         :string
#  read_at       :datetime
#  created_at    :datetime
#  notice_for_id :integer
#  url           :string
#  updated_at    :datetime
#

class Notice < ApplicationRecord
  include Defaults
  include Readable
  include UrlHelper

  belongs_to :user

  scope :by_type, ->(*types) { where(notice_type: Notice.notice_types.symbolize_keys.slice(*types.map(&:to_sym)).values) }

  defaults notice_type: :other

  after_create :notify_user
  after_commit :broadcast_creation

  enum notice_type: {
    other:              0,
    subscription:       1,
    questionable_reply: 2,
    friend_request:     3
  }

  def notice_message(passed_root: nil)
    case notice_type.to_sym
    when :other              then generic_message(passed_root: passed_root)
    when :subscription       then subscription_message(passed_root: passed_root)
    when :questionable_reply then questionable_message(passed_root: passed_root)
    when :friend_request     then friend_request_message(passed_root: passed_root)
    else "[INVALID]"
    end
  end

  def generic_message(passed_root: nil)
    link_to(title.presence || "New Notice", url, passed_root: passed_root).html_safe
  end

  def subscription_message(passed_root: nil)
    post = Post.find(notice_for_id)
    post_path = Rails.application.routes.url_helpers.post_path(post)
    "New Comment on #{link_to(post.title, post_path, passed_root: passed_root)}".html_safe
  end

  def questionable_message(passed_root: nil)
    reply = Reply.find(notice_for_id)
    post = reply.post
    read unless reply.in_moderation?
    reply_path = Rails.application.routes.url_helpers.post_path(post) + "#reply-#{notice_for_id}"
    "Questionable Reply on #{link_to(post.title, reply_path, passed_root: passed_root)}".html_safe
  end

  def friend_request_message(passed_root: nil)
    new_fan = User.find(notice_for_id)
    friends_path = Rails.application.routes.url_helpers.account_friends_path
    "New Friend Request from #{link_to(new_fan.username, friends_path, passed_root: passed_root)}".html_safe
  end

  private

  def broadcast_creation
    if updated_at == created_at
      ActionCable.server.broadcast("notifications_#{user_id}", message: notice_message)
    else
      ActionCable.server.broadcast("notifications_#{user_id}", {})
    end
  end

  def notify_user
    return unless user.settings.send_reply_notifications?
    return if user.online? || user.banned?
    if subscription?
      post_subscription = user.subscriptions.find_by(post_id: notice_for_id)
      if post_subscription
        previous_notification = post_subscription.last_notified_at || DateTime.new
        post_subscription.update(last_notified_at: 30.seconds.from_now) # Catch race conditions
        return if previous_notification > 30.minutes.ago
      end
    end
    UserMailer.notifications(user, notice_message(passed_root: root_domain)).deliver_later
  end

end
