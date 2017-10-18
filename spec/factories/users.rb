# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string
#  last_seen_at           :datetime
#  avatar_url             :string
#  verified_at            :datetime
#  date_of_birth          :date
#  has_updated_username   :boolean          default("false")
#  bio                    :text
#  slug                   :string
#  role                   :integer          default("0")
#  completed_signup       :boolean          default("false")
#

FactoryGirl.define do
  factory :user, class: User do
    email
    password
    username
  end
end
