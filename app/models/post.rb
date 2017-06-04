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

class Post < ApplicationRecord

  belongs_to :author, class_name: "User"

  scope :claimed, -> { where(posted_anonymously: false) }
  scope :unclaimed, -> { where(posted_anonymously: true) }

  # validates presence of title / body

  def title
    first_sentence = body.split(/!|\.|\n|;|\?|\r/).reject(&:blank?).first
    body[0..first_sentence.try(:length) || -1]
  end

  def short_title
    cut_title = cut_string_before_index_at_char(title, 100)
    return cut_title if cut_title.length <= 100
    "#{cut_title}..."
  end

  def cut_string_before_index_at_char(str, idx, letter=" ")
    return str if str.length <= idx
    indices_of_letter = str.split("").map.with_index { |l, i| i if l == letter }.compact
    indices_before_index = indices_of_letter.select { |i| i <= idx }
    str[0..indices_before_index.last.to_i - 1]
  end

end
