# == Schema Information
#
# Table name: post_tags
#
#  id      :integer          not null, primary key
#  tag_id  :integer
#  post_id :integer
#

class PostTag < ApplicationRecord
  belongs_to :tag
  belongs_to :post
end
