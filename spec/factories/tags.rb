# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  tag_name   :string
#  tags_count :integer
#

FactoryGirl.define do
  factory :tag do
    tag_name Faker::Lorem.word
  end
end
