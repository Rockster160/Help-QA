# == Schema Information
#
# Table name: post_views
#
#  id           :integer          not null, primary key
#  post_id      :integer
#  viewed_by_id :integer
#  created_at   :datetime
#

FactoryGirl.define do
  factory :post_view do
    viewed_by :user
    post
  end
end
