# == Schema Information
#
# Table name: replies
#
#  id                 :integer          not null, primary key
#  body               :text
#  author_id          :integer
#  posted_anonymously :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  post_id            :integer
#  removed_at         :datetime
#  marked_as_adult    :boolean
#  favorite_count     :integer          default("0")
#  in_moderation      :boolean          default("false")
#

FactoryGirl.define do
  factory :reply do
    author :user
    body
  end
end
