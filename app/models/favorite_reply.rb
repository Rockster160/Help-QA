# == Schema Information
#
# Table name: favorite_replies
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  post_id    :integer
#  reply_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FavoriteReply < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :reply

  validate :can_only_favorite_one_reply_per_post

  private

  def can_only_favorite_one_reply_per_post
    return if post.favorite_replies.where(user_id: user_id).where.not(id: id).none?

    errors.add(:base, "You have already favorited a reply to this post!")
  end
end
