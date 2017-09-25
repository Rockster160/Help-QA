# == Schema Information
#
# Table name: user_poll_votes
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  poll_option_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class UserPollVote < ApplicationRecord
  belongs_to :user
  belongs_to :poll_option

  delegate :poll, to: :poll_option

  validate :not_voted_multiple_times

  private

  def not_voted_multiple_times
    return if poll.votes.where(user_id: user_id).none?

    errors.add(:base, "You have already voted on this poll!")
  end
end
