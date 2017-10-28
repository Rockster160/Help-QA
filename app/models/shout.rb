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
#

class Shout < ApplicationRecord
  include Readable
  belongs_to :sent_from, class_name: "User"
  belongs_to :sent_to,   class_name: "User"

  scope :between, ->(user1, user2) { where("(sent_from_id = :user1 AND sent_to_id = :user2) OR (sent_from_id = :user2 AND sent_to_id = :user1)", user1: user1, user2: user2) }
  scope :not_banned, -> { joins(:sent_from).where("users.banned_until IS NULL OR users.banned_until < ?", DateTime.current) }

  after_commit :broadcast_creation

  private

  def shouts_path
    Rails.application.routes.url_helpers.user_shouts_path(sent_to_id, anchor: "shout-#{id}")
  end

  def broadcast_creation
    if updated_at == created_at
      ActionCable.server.broadcast("notifications_#{sent_to_id}", message: "New Shout from <a href=\"#{shouts_path}\">#{sent_from.username}</a>".html_safe)
    else
      ActionCable.server.broadcast("notifications_#{sent_to_id}", {})
    end
  end
end
