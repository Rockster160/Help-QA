# == Schema Information
#
# Table name: post_tags
#
#  id      :integer          not null, primary key
#  tag_id  :integer
#  post_id :integer
#

FactoryGirl.define do
  factory :post_tag do
    tag
    post
  end
end
