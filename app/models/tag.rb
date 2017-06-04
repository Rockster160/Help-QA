# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  tag_name   :string
#  tags_count :integer
#

class Tag < ApplicationRecord
  has_many :post_tags
  has_many :posts, through: :post_tags
end
