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

FactoryGirl.define do
  factory :subscription do
    post
    user
  end
end
