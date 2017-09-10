# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  tag_name   :string
#  tags_count :integer
#

class Tag < ApplicationRecord
  include Defaults

  defaults tags_count: 0

  before_save :format_name

  has_many :post_tags
  has_many :posts, through: :post_tags
  has_many :user_tags
  has_many :users, through: :user_tags

  scope :count_order, -> { order("tags.tags_count DESC NULLS LAST") }

  def self.auto_extract_tags_from_body(body)
    stop_word_regex = stop_words.map { |word| Regexp.quote(word) }.join("|")
    formatted = body.gsub("\n", " ")                       # Spaces instead of newlines
                    .gsub(/[^a-z| ]/i, "")                 # Without special chars
                    .gsub(/\b[a-z]{1,2}\b/i, "")           # Without shorts (1-2 character words)
                    .gsub(/\b(#{stop_word_regex})\b/i, "") # Without stop words
    formatted.squish.split(" ")
  end

  def self.stop_words
    @@stop_words ||= File.read("lib/tag_stop_words.txt").split("\n").reject(&:blank?)
  end

  def to_param
    tag_name.downcase || id
  end

  private

  def format_name
    tag_name = self.tag_name.downcase.squish
  end

end
