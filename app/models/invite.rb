# == Schema Information
#
# Table name: invites
#
#  id              :integer          not null, primary key
#  from_user_id    :integer
#  invited_user_id :integer
#  post_id         :integer
#  created_at      :datetime
#

class Invite < ApplicationRecord

  belongs_to :from_user,    class_name: "User"
  belongs_to :invited_user, class_name: "User"
  belongs_to :post

end
