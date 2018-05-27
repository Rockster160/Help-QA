# == Schema Information
#
# Table name: friendships
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  friend_id       :integer
#  created_at      :datetime
#  shared_email_at :datetime
#

class Friendship < ApplicationRecord

  belongs_to :user
  belongs_to :friend, class_name: "User"

  def shared_email?
    shared_email_at?
  end

  def reveal_email=(new_val)
    self.shared_email_at = new_val.to_s.downcase == "true" ? DateTime.current : nil
  end

end
