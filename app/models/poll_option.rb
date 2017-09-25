# == Schema Information
#
# Table name: poll_options
#
#  id         :integer          not null, primary key
#  poll_id    :integer
#  body       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PollOption < ApplicationRecord
  belongs_to :poll
  has_many :votes, class_name: "UserPollVote"
end
