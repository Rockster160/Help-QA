# == Schema Information
#
# Table name: invites
#
#  id                  :integer          not null, primary key
#  from_user_id        :integer
#  invited_user_id     :integer
#  post_id             :integer
#  created_at          :datetime
#  reply_id            :integer
#  read_at             :datetime
#  updated_at          :datetime
#  invited_anonymously :boolean          default("false")
#

class Invite < ApplicationRecord
  include Readable

  belongs_to :from_user,    class_name: "User"
  belongs_to :invited_user, class_name: "User"
  belongs_to :post
  belongs_to :reply, optional: true

  after_commit :broadcast_creation

  validate :cannot_invite_helpbot

  def display_name
    if invited_anonymously?
      "Anonymous"
    else
      from_user.username
    end
  end

  def notice_message
    "#{display_name} mentioned you in the post <a href=\"#{invite_link}\">#{post.title}</a>".html_safe
  end

  def groupable_identifier
    reply.present? ? "reply-#{reply_id}" : "post-#{post_id}"
  end

  private

  def broadcast_creation
    if read?
      ActionCable.server.broadcast("notifications_#{invited_user_id}", {})
    else
      ActionCable.server.broadcast("notifications_#{invited_user_id}", message: notice_message)
    end
  end

  def invite_link
    if reply_id.present?
      Rails.application.routes.url_helpers.post_path(post_id, anchor: "reply-#{reply_id}")
    else
      Rails.application.routes.url_helpers.post_path(post_id)
    end
  end

  def cannot_invite_helpbot
    errors.add(:base, "Helpbot cannot be invited to posts") if invited_user.helpbot?
  end
end
