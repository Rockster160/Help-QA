# == Schema Information
#
# Table name: friendships
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  friend_id   :integer
#  accepted_at :datetime
#  created_at  :datetime
#

class Friendship < ApplicationRecord

  belongs_to :user
  belongs_to :friend, class_name: "User"

  def friends?
    accepted_at?
  end

end
