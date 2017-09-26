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

  belongs_to :user

  defaults notice_type: :other

  enum notice_type: {
    other:          0,
    subscription:   1,
    friend_request: 2
  }

  def notice_message
    case notice_type.to_sym
    when :other then generic_message
    when :subscription then subscription_message
    when :friend_request then friend_message
    else "[INVALID]"
    end
  end

  def generic_message
    link_to(title.presence || "New Notice", url).html_safe
  end

  def subscription_message
    post = Post.find(notice_for_id)
    post_path = Rails.application.routes.url_helpers.post_path(post)
    "New Comment on <a href=\"#{post_path}\">#{post.title}</a>".html_safe
  end

  def friend_message
    new_fan = User.find(notice_for_id)
    user_path = Rails.application.routes.url_helpers.user_path(new_fan)
    "New Friend Request from #{link_to(new_fan.username, user_path)}".html_safe
  end

  def link_to(text, url)
    "<a href=\"#{url}\">#{title}</a>"
  end

end
