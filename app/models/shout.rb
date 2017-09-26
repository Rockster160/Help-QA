# == Schema Information
#
# Table name: shouts
#
#  id           :integer          not null, primary key
#  sent_from_id :integer
#  sent_to_id   :integer
#  body         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  read_at      :datetime
#

class Shout < ApplicationRecord
  include Readable
  belongs_to :sent_from, class_name: "User"
  belongs_to :sent_to,   class_name: "User"

  scope :between, ->(user1, user2) { where("(sent_from_id = :user1 AND sent_to_id = :user2) OR (sent_from_id = :user2 AND sent_to_id = :user1)", user1: user1, user2: user2) }
end
