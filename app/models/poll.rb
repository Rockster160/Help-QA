# == Schema Information
#
# Table name: polls
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Poll < ApplicationRecord
  belongs_to :post
  has_many :options, class_name: "PollOption"
  has_many :votes, through: :options

  def answered_by?(user)
    options.joins(:votes).where(user_poll_votes: { user_id: user.try(:id) }).any?
  end
end
