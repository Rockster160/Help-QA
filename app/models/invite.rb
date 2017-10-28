# == Schema Information
#
# Table name: invites
#
#  id              :integer          not null, primary key
#  from_user_id    :integer
#  invited_user_id :integer
#  post_id         :integer
#  created_at      :datetime
#  reply_id        :integer
#  read_at         :datetime
#

class Invite < ApplicationRecord
  include Readable

  belongs_to :from_user,    class_name: "User"
  belongs_to :invited_user, class_name: "User"
  belongs_to :post
  belongs_to :reply

  after_commit :broadcast_creation

  def notice_message
    "#{from_user.username} invited you to the post <a href=\"#{link_to_reply}\">#{post.title}</a>".html_safe
  end

  private

  def broadcast_creation
    if updated_at == created_at
      ActionCable.server.broadcast("notifications_#{invited_user_id}", message: notice_message)
    else
      ActionCable.server.broadcast("notifications_#{invited_user_id}", {})
    end
  end

  def link_to_reply
    Rails.application.routes.url_helpers.post_path(post_id, anchor: "reply-#{reply_id}")
  end
end
