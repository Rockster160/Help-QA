# == Schema Information
#
# Table name: post_edits
#
#  id            :integer          not null, primary key
#  post_id       :integer
#  edited_by_id  :integer
#  edited_at     :datetime
#  previous_body :text
#

class PostEdit < ApplicationRecord

  belongs_to :post
  belongs_to :edited_by, class_name: "User"
  
end
