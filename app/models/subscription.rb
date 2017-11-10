# == Schema Information
#
# Table name: subscriptions
#
#  id               :integer          not null, primary key
#  post_id          :integer
#  user_id          :integer
#  created_at       :datetime
#  unsubscribed     :boolean
#  last_notified_at :datetime
#

class Subscription < ApplicationRecord

  belongs_to :post
  belongs_to :user

  scope :subscribed, -> { where(unsubscribed: [nil, false]) }

  def subscribed?
    !unsubscribed?
  end

end
