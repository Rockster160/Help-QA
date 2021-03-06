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
#  reply_count        :integer
#  marked_as_adult    :boolean
#  in_moderation      :boolean          default("false")
#  removed_at         :datetime
#

FactoryGirl.define do
  factory :post do
    author { ::FactoryGirl.create(:user) }
    body
  end
end
