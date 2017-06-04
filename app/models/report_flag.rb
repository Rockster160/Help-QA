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
end
