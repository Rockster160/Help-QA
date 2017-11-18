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

  validate :has_not_already_been_invited, :is_not_already_subscribed
  after_commit :broadcast_creation

  def display_name
    if invited_anonymously?
      "Anonymous"
    else
      from_user.username
    end
  end

  def notice_message
    "#{display_name} invited you to the post <a href=\"#{invite_link}\">#{post.title}</a>".html_safe
  end

  def groupable_identifier
    "post-#{post_id}"
  end

  private

  def has_not_already_been_invited
    return unless new_record?
    if post.invites.where.not(id: id).where(invited_user_id: invited_user_id).any?
      errors.add(:base, "User has already been invited to this post.")
    end
  end

  def is_not_already_subscribed
    return unless new_record?
    if invited_user.subscriptions.where(post_id: post_id).any?
      errors.add(:base, "User is already subscribed to post.")
    end
  end

  def broadcast_creation
    if updated_at == created_at
      ActionCable.server.broadcast("notifications_#{invited_user_id}", message: notice_message)
    else
      ActionCable.server.broadcast("notifications_#{invited_user_id}", {})
    end
  end

  def invite_link
    if reply_id.present?
      Rails.application.routes.url_helpers.post_path(post_id, anchor: "reply-#{reply_id}")
    else
      Rails.application.routes.url_helpers.post_path(post_id)
    end
  end
end
