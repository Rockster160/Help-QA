# == Schema Information
#
# Table name: notices
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  notice_type :integer
#  title       :string
#  description :string
#  read_at     :datetime
#  created_at  :datetime
#

class Notice < ApplicationRecord
  include Defaults

  belongs_to :user

  defaults notice_type: :other

  scope :unread, -> { where(read_at: nil) }

  enum notice_type: {
    other:         0,
    subscriptions: 1,
    shouts:        2,
    invites:       3
  }

end
