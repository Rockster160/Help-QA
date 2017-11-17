# == Schema Information
#
# Table name: post_invites
#
#  id                  :integer          not null, primary key
#  post_id             :integer
#  user_id             :integer
#  invited_users       :integer
#  invited_anonymously :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class PostInvite < ApplicationRecord
  belongs_to :user
  belongs_to :post
end
