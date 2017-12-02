# == Schema Information
#
# Table name: user_profiles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  about      :text
#  grow_up    :text
#  live_now   :text
#  education  :text
#  subjects   :text
#  sports     :text
#  jobs       :text
#  hobbies    :text
#  causes     :text
#  political  :text
#  religion   :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserProfile < ApplicationRecord
  include Sherlockable

  sherlockable klass: :user, ignore: [ :created_at, :updated_at ], skip: :new
  belongs_to :user

  def editable_attributes
    {
      about:     "Bio (Tell us about yourself)",
      grow_up:   "Where did you grow up?",
      live_now:  "Where do you live now?",
      education: "What is the highest level of education you have attained?",
      subjects:  "What subjects did/do you enjoy most at school?",
      sports:    "What's your favorite sport or sports?",
      jobs:      "What kind of jobs have you held? Industries too!",
      hobbies:   "What hobbies are you into?",
      causes:    "What causes are you concerned about today?",
      political: "If you claim a political party affiliation, which is it?",
      religion:  "Which religion (if any) do you follow?"
    }
  end
end
