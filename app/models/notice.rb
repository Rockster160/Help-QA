# == Schema Information
#
# Table name: notices
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  notice_type   :integer
#  title         :string
#  read_at       :datetime
#  created_at    :datetime
#  notice_for_id :integer
#  url           :string
#

class Notice < ApplicationRecord
  include Defaults
  include Readable

  belongs_to :user

  defaults notice_type: :other

  scope :unread, -> { where(read_at: nil) }

  enum notice_type: {
    other:           0,
    subscriptions:   1,
    friend_requests: 2
  }

end
