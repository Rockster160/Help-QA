# == Schema Information
#
# Table name: posts
#
#  id                 :integer          not null, primary key
#  body               :text
#  author_id          :integer
#  posted_anonymously :boolean
#  closed_at          :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryGirl.define do
  factory :post do
    author :user
    body
  end
end
