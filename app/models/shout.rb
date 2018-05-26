# == Schema Information
#
# Table name: shouts
#
#  id           :integer          not null, primary key
#  sent_from_id :integer
#  sent_to_id   :integer
#  body         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  read_at      :datetime
#  removed_at   :datetime
#

class Shout < ApplicationRecord
  include Readable
  include UrlHelper
  include Sherlockable

  sherlockable klass: :shout, ignore: [ :created_at, :updated_at, :read_at ]

  belongs_to :sent_from, class_name: "User"
  belongs_to :sent_to,   class_name: "User"

  scope :between, ->(user1, user2) { where("(sent_from_id = :user1 AND sent_to_id = :user2) OR (sent_from_id = :user2 AND sent_to_id = :user1)", user1: user1, user2: user2) }
  scope :not_banned, -> { joins(:sent_from).where("users.banned_until IS NULL OR users.banned_until < ?", DateTime.current) }
  scope :not_removed, -> { where(shouts: { removed_at: nil }) }
  scope :displayable, -> { not_banned unless Rails.env.archive? }

  after_commit :broadcast_creation, :notify_user

  validate :valid_text

  def removed?; removed_at?; end

  def restore=(val)
    self.removed_at = nil if val.to_s.downcase == "true"
  end

  private

  def valid_text
    if body.to_s.length == 0
      errors.add(:base, "Try adding some more text! This isn't long enough.")
    end
  end

  def shouts_path
    Rails.application.routes.url_helpers.user_shouts_path(sent_to_id, anchor: "shout-#{id}")
  end

  def notify_user
    return unless updated_at == created_at
    return unless sent_to.settings.send_reply_notifications?
    return if sent_to.online? || sent_to.banned?
    shout_path = url_for(Rails.application.routes.url_helpers.user_shouttrail_path(sent_to, sent_from))
    UserMailer.notifications(sent_to, "New Shout from <a href=\"#{shout_path}\">#{sent_from.username}</a>").deliver_later
  end

  def broadcast_creation
    if updated_at == created_at
      ActionCable.server.broadcast("notifications_#{sent_to_id}", message: "New Shout from <a href=\"#{shouts_path}\">#{sent_from.username}</a>".html_safe)
    else
      ActionCable.server.broadcast("notifications_#{sent_to_id}", {})
    end
  end
end
