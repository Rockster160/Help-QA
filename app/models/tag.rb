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

  scope :count_order, -> { order("tags.tags_count DESC NULLS LAST") }

  def self.auto_extract_tags_from_body(body)
    stop_word_regex = stop_words.map { |word| Regexp.quote(word) }.join("|")
    formatted = body.gsub("\n", " ")                       # Spaces instead of newlines
                    .gsub(/[^a-z \-]/i, "")                # Without special chars (Include alpha, spaces, and hyphens)
                    .gsub(/\b[a-z]{1,2}\b/i, "")           # Without shorts (1-2 character words)
                    .gsub(/ \-|\- /i, "")                  # Remove hyphens at beginning and end of words
                    .gsub(/\b(#{stop_word_regex})\b/i, "") # Without stop words
    tags = formatted.squish.split(" ")
    add_similar_common_tags_to_tags_list(tags)
    # Sort tags by how often then occur
  end

  def self.stop_words
    @@stop_words ||= File.read("lib/tag_stop_words.txt").split("\n").reject { |word| word.to_s.length < 2 }
  end

  def self.adult_words
    @@adult_words ||= File.read("lib/adult_words.txt").split("\n").reject { |word| word.to_s.length < 2 }
  end

  def self.auto_mapper_hash
    {
      depression: [
        :sad,
        :crying,
      ],
      suicide: [
        :"self-harm"
      ]
    }
  end

  def self.add_similar_common_tags_to_tags_list(tags)
    auto_mapper_hash.each do |mapped_to, mapped_from|
      tags.push(mapped_to.to_s) if tags.include?(mapped_from.to_s)
    end
    tags.reverse
  end

  def self.adult_words_in_body(body)
    auto_extract_tags_from_body(body).map(&:downcase) & adult_words
  end

  def self.adult_words_in_list(list)
    list & adult_words
  end

  def self.tags_list_contains_adult_words?(tags)
    adult_words_in_list(tags).any?
  end

  def similar_tags(required_to_match=2)
    all_tag_ids_used_in_posts = posts.map(&:tag_ids).flatten - [id]
    tag_occurence_counter = all_tag_ids_used_in_posts.each_with_object(Hash.new(0)) { |instance, count_hash| count_hash[instance] += 1 }
    strong_matches = tag_occurence_counter.reject { |tag_id, similar_count| similar_count <= required_to_match }
    return Tag.none if strong_matches.none?

    sorted_occurences = Hash[strong_matches.sort_by { |tag_id, similar_count| -similar_count }]
    psql_order_str = ["CASE"] + sorted_occurences.keys.map.with_index { |tag_id, idx| "WHEN id='#{tag_id}' THEN #{idx}" } + ["END"]
    Tag.where(id: sorted_occurences.keys).order(psql_order_str.join(" "))
  end

  def to_param
    tag_name.downcase || id
  end

  private

  def format_name
    tag_name = self.tag_name.downcase.squish
  end

end
