# == Schema Information
#
# Table name: notices
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  notice_type   :integer
#  title         :string
#  description   :string
#  notice_for_id :integer
#  read_at       :datetime
#  created_at    :datetime
#

class Notice < ApplicationRecord
  include Defaults

  belongs_to :user

  defaults notice_type: :other

  scope :unread, -> { where(read_at: nil) }

  enum notice_type: {
    other:           0,
    subscriptions:   1,
    shouts:          2,
    invites:         3,
    friend_requests: 4
  }

  def notice_for
    return unless notice_for_id.present?
    case notice_type.to_sym
    when :subscriptions then Subscription.find(notice_for_id)
    when :shouts        then Shout.find(notice_for_id)
    when :invites       then Invite.find(notice_for_id)
    end
  end

  def read!(now=DateTime.current)
    update!(read_at: now)
  end

end
