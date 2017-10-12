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
#

class Notice < ApplicationRecord
  include Defaults
  include Readable
  include UrlHelper

  belongs_to :user

  scope :by_type, ->(*types) { where(notice_type: Notice.notice_types.symbolize_keys.slice(types.map(&:to_sym)).values) }

  defaults notice_type: :other

  enum notice_type: {
    other:              0,
    subscription:       1,
    friend_request:     2,
    questionable_reply: 3,
    friend_approval:    4
  }

  def notice_message
    case notice_type.to_sym
    when :other              then generic_message
    when :subscription       then subscription_message
    when :friend_request     then friend_request_message
    when :friend_approval    then friend_approval_message
    when :questionable_reply then questionable_message
    else "[INVALID]"
    end
  end

  def generic_message
    link_to(title.presence || "New Notice", url).html_safe
  end

  def subscription_message
    post = Post.find(notice_for_id)
    post_path = Rails.application.routes.url_helpers.post_path(post)
    "New Comment on #{link_to(post.title, post_path)}".html_safe
  end

  def friend_request_message
    new_fan = User.find(notice_for_id)
    friends_path = Rails.application.routes.url_helpers.account_friends_path
    "New Friend Request from #{link_to(new_fan.username, friends_path)}".html_safe
  end

  def friend_approval_message
    new_friend = User.find(notice_for_id)
    friends_path = Rails.application.routes.url_helpers.account_friends_path
    "#{link_to(new_friend.username, friends_path)} has accepted your friend request!".html_safe
  end

  def questionable_message
    reply = Reply.find(notice_for_id)
    post = reply.post
    read unless reply.has_questionable_text?
    reply_path = Rails.application.routes.url_helpers.post_path(post) + "#reply-#{notice_for_id}"
    "Questionable Reply on #{link_to(post.title, reply_path)}".html_safe
  end

end
