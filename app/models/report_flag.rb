# == Schema Information
#
# Table name: report_flags
#
#  id             :integer          not null, primary key
#  reported_by_id :integer
#  user_id        :integer
#  post_id        :integer
#  comment_id     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class ReportFlag < ApplicationRecord
  belongs_to :reported_by, class_name: "User"
  belongs_to :user, optional: true
  belongs_to :comment, optional: true
  belongs_to :post, optional: true

  # validates belongs to one of the above
end
