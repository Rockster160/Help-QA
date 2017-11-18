# == Schema Information
#
# Table name: tags
#
#  id                    :integer          not null, primary key
#  tag_name              :string
#  tags_count            :integer
#  similar_tag_id_string :text
#

class Tag < ApplicationRecord
  include Defaults
  include Frequency

  defaults tags_count: 0

  before_save :format_name

  after_commit { delay.set_similar_tags }

  has_many :post_tags
  has_many :posts, through: :post_tags
  has_many :users, through: :posts, source: :author

  scope :count_order, -> { order("tags.tags_count DESC NULLS LAST") }
  scope :by_words, ->(*words) { where(tag_name: [words].flatten.map { |word| word.try(:downcase).try(:squish) }.compact) }

  def self.auto_extract_tags_from_body(body)
    stop_word_regex = stop_words.map { |word| Regexp.quote(word) }.join("|")
    url_split_regex = /((http[s]?|ftp):\/?\/?)([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)(.*)?(#[\w\-]+)?/
    formatted = body.gsub(url_split_regex) { $3.split(".")[-2] || $3 } # Replace URL with just the Host for tagging purposes
                    .gsub("\n", " ")                       # Spaces instead of newlines
                    .gsub(/[\.\!\?]/i, " ")                # Remove punctuation
                    .gsub(/[^a-z \-]/i, "")                # Without special chars (Include alpha, spaces, and hyphens)
                    .gsub(/\b[a-z]{1,2}\b/i, "")           # Without shorts (1-2 character words)
                    .gsub(/ \-|\- /i, "")                  # Remove hyphens at beginning and end of words
                    .gsub(/\b(#{stop_word_regex})\b/i, "") # Without stop words
    tags = formatted.squish.split(" ")
    tags = add_similar_common_tags_to_tags_list(tags)
    sort_frequency(tags)
  end

  def self.sounds_depressed?(body)
    (depressed_words & body.downcase.gsub(/[^a-z ]/i, "").split(" ")).any?
  end

  def self.depressed_words
    @@depressed_words ||= File.read("lib/sad_words.txt").split("\n").reject(&:blank?)
  end

  def self.stop_words
    @@stop_words ||= File.read("lib/tag_stop_words.txt").split("\n").reject { |word| word.to_s.length < 2 }
  end

  def self.adult_words
    @@adult_words ||= File.read("lib/adult_words.txt").split("\n").reject { |word| word.to_s.length < 2 }
  end

  def self.tags_grouped_by_similar
    # Warning: Slow method
    tag_hash = {}
    Tag.find_each { |tag| tag_hash[tag.tag_name] = tag.similar_tags.map(&:tag_name) }
    tag_hash.reject! { |tag_name, similar_tags| similar_tags.none? }
    tag_hash
  end

  def self.auto_mapper_hash
    {
      depression: [
        :sad,
        :crying,
        :cry,
        :sorrow,
        :dead,
        :dread
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

  def self.similar_tags
    tags = all
    similar_ids = tags.map(&:similar_tag_ids).inject(&:&)
    return none if similar_ids.blank?
    unscoped.where(id: similar_ids -  tags.pluck(:id))
  end

  def similar_tag_ids
    similar_tag_id_string.to_s.split(",").map(&:to_i).reject(&:zero?)
  end

  def similar_tags
    where(id: similar_tag_ids)
  end

  def ordered_similar_tags
    sorted_occurences = similar_tag_ids
    psql_order_str = ["CASE"] + sorted_occurences.map.with_index { |tag_id, idx| "WHEN id='#{tag_id}' THEN #{idx}" } + ["END"]
    where(id: sorted_occurences).order(psql_order_str.join(" "))
  end

  def set_similar_tags
    return unless persisted?

    required_to_match = 2
    all_tag_ids_used_in_posts = posts.map(&:tag_ids).flatten - [id]
    tag_occurence_counter = all_tag_ids_used_in_posts.each_with_object(Hash.new(0)) { |instance, count_hash| count_hash[instance] += 1 }
    strong_matches = tag_occurence_counter.reject { |tag_id, similar_count| similar_count <= required_to_match } # Less than or equal here because it INCLUDES the initial tag. So 3 occurrences of the tag mean there are 2 other posts with the same tag combo
    if strong_matches.none?
      update(similar_tag_id_string: "")  if similar_tag_id_string.present?
      return
    end

    sorted_occurences = Hash[strong_matches.sort_by { |tag_id, similar_count| -similar_count }]
    new_str = ",#{sorted_occurences.keys.join(',')}," # Commas on either side to allow the fuzzy search to pick up the start and end
    unless new_str == similar_tag_id_string
      update(similar_tag_id_string: new_str)
    end
  end

  def to_param
    tag_name.downcase || id
  end

  private

  def format_name
    tag_name = self.tag_name.downcase.squish
  end

end
