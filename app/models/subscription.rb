# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  user_id    :integer
#  created_at :datetime
#

class Subscription < ApplicationRecord
end
