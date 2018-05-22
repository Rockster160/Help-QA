# == Schema Information
#
# Table name: subscriptions
#
#  id               :integer          not null, primary key
#  post_id          :integer
#  user_id          :integer
#  created_at       :datetime
#  last_notified_at :datetime
#  unsubscribed_at  :datetime
#

class Subscription < ApplicationRecord

  belongs_to :post
  belongs_to :user

  scope :subscribed,   -> { where(unsubscribed_at: nil) }
  scope :unsubscribed, -> { where.not(unsubscribed_at: nil) }
  scope :not_removed, -> { joins(:post).merge(Post.not_removed) }

  def unsubscribed?; unsubscribed_at?; end
  def subscribed?; !unsubscribed?; end

end
