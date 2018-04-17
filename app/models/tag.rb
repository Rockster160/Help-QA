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

  after_commit { delay(:set_similar_tags) }

  has_many :post_tags
  has_many :posts, through: :post_tags
  has_many :users, through: :posts, source: :author

  scope :count_order, -> { order("tags.tags_count DESC NULLS LAST") }
  scope :by_words, ->(*words) { where(tag_name: [words].flatten.map { |word| word.try(:downcase).try(:squish) }.compact) }

  class << self
    def auto_extract_tags_from_body(body)
      return if body.blank?
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

    def sounds_depressed?(body)
      body.match(regex_for_words(depressed_words)).present?
    end

    def sounds_nsfw?(body)
      body.match(regex_for_words(adult_words)).present?
    end

    def regex_for_words(words)
      Regexp.new("\\b(#{words.join("|")})\\b", :i)
    end

    def words_from_file(file)
      File.read(file).split("\n").reject { |word| word.to_s.length < 2 }
    end

    def depressed_words
      @@depressed_words ||= words_from_file("lib/sad_words.txt")
    end

    def stop_words
      @@stop_words ||= words_from_file("lib/tag_stop_words.txt")
    end

    def adult_words
      @@adult_words ||= words_from_file("lib/adult_words.txt")
    end

    def tags_grouped_by_similar
      # Warning: Slow method
      tag_hash = {}
      Tag.find_each { |tag| tag_hash[tag.tag_name] = tag.similar_tags.map(&:tag_name) }
      tag_hash.reject! { |tag_name, similar_tags| similar_tags.none? }
      tag_hash
    end

    def auto_mapper_hash
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

    def add_similar_common_tags_to_tags_list(tags)
      auto_mapper_hash.each do |mapped_to, mapped_from|
        tags.push(mapped_to.to_s) if tags.include?(mapped_from.to_s)
      end
      tags.reverse
    end

    def similar_tags
      tags = all
      similar_ids = tags.map(&:similar_tag_ids).inject(&:&)
      return none if similar_ids.blank?
      unscoped.where(id: similar_ids -  tags.pluck(:id))
    end
  end

  def similar_tag_ids
    similar_tag_id_string.to_s.split(",").map(&:to_i).reject(&:zero?)
  end

  def similar_tags
    self.class.where(id: similar_tag_ids)
  end

  def ordered_similar_tags
    sorted_occurences = similar_tag_ids
    psql_order_str = ["CASE"] + sorted_occurences.map.with_index { |tag_id, idx| "WHEN id='#{tag_id}' THEN #{idx}" } + ["END"]
    where(id: sorted_occurences).order(psql_order_str.join(" "))
  end

  def set_similar_tags
    return unless persisted?

    required_to_match = 2
    posts_tag_used_in = posts.reload
    other_tag_ids_from_same_posts = posts_tag_used_in.map(&:tag_ids).flatten - [id]

    tags_by_occurrence_count = other_tag_ids_from_same_posts.each_with_object(Hash.new(0)) { |instance, count_hash| count_hash[instance] += 1 }
    strong_matched_tags = tags_by_occurrence_count.reject { |tag_id, similar_count| similar_count <= required_to_match } # Less than or equal here because it INCLUDES the initial tag. So 3 occurrences of the tag mean there are 2 other posts with the same tag combo

    sorted_tag_ids_by_relevance = Hash[strong_matched_tags.sort_by { |tag_id, similar_count| -similar_count }].keys
    new_similar_tag_string = ",#{sorted_tag_ids_by_relevance.join(',')}," # Commas on either side to allow the fuzzy search to pick up the start and end

    return if new_similar_tag_string == self.similar_tag_id_string
    update(similar_tag_id_string: new_similar_tag_string)
    Tag.where(id: sorted_tag_ids_by_relevance).find_each(&:set_similar_tags)
  end

  def to_param
    tag_name.downcase || id
  end

  private

  def format_name
    tag_name = self.tag_name.downcase.squish
  end

end
