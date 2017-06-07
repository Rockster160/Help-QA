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
#

class Shout < ApplicationRecord
  belongs_to :sent_from, class_name: "User"
  belongs_to :sent_to, class_name: "User"
end
