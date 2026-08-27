# == Schema Information
#
# Table name: post_views
#
#  id           :integer          not null, primary key
#  post_id      :integer
#  viewed_by_id :integer
#  created_at   :datetime
#

FactoryBot.define do
  factory :post_view do
    association :viewed_by, factory: :user
    post
  end
end
