# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  tag_name   :string
#  tags_count :integer
#

class Tag < ApplicationRecord

  has_many :post_tags
  has_many :posts, through: :post_tags

  scope :count_order, -> { order(tags_count: :desc) }

  def self.auto_extract_tags_from_body(body)
    stop_word_regex = stop_words.map { |word| Regexp.quote(word) }.join("|")
    without_shorts = body.gsub(/\b[a-z]{1,2}\b/i, "")
    without_stop_words = without_shorts.gsub(/\b(#{stop_word_regex})\b/i, "")
    without_special_chars = without_stop_words.gsub(/[^a-z| ]/i, "")
    without_special_chars.squish.split(" ")
  end

  def self.stop_words
    @@stop_words ||= File.read("lib/tag_stop_words.txt").split("\n")
  end

end
