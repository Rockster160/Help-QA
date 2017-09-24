# == Schema Information
#
# Table name: replies
#
#  id                    :integer          not null, primary key
#  body                  :text
#  author_id             :integer
#  posted_anonymously    :boolean
#  has_questionable_text :boolean
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  post_id               :integer
#

class Reply < ApplicationRecord
  include Anonicon

  belongs_to :post, counter_cache: :reply_count
  belongs_to :author, class_name: "User"
  has_many :tags, through: :post

  # before_validation :format_body

  scope :claimed, -> { where.not(posted_anonymously: true) }
  scope :unclaimed, -> { where(posted_anonymously: true) }
  # TODO Add validation requiring text, cannot be blank, cannot be "Leave a reply" or similar

  def username
    if posted_anonymously?
      "Anonymous"
    else
      author.username
    end
  end

  def avatar
    if posted_anonymously?
      anonicon_src(author.ip_address)
    else
      author.avatar_url.presence || letter.presence || 'status_offline.png'
    end
  end

  def letter
    author.try(:letter) || "?"
  end

  def location
    return unless author.try(:location)
    [author.location.city.presence, author.location.region_code.presence, author.location.country_code.presence].compact.join(", ")
  end

  def same_author_as_post?
    author_id == post.author_id && posted_anonymously? == post.posted_anonymously?
  end

  private

  def anonicon_src(ip)
    Anonicon.generate(ip)
  end

  def format_body
    remove_quotes_nested_greater_than(3)
  end

  def remove_quotes_nested_greater_than(max_nest_level)
    temp_body = body.dup
    @quotes = []

    loop do
      last_start_quote_idx = temp_body.rindex(/\[quote(.*?)\]/)
      break if last_start_quote_idx.nil?
      next_end_quote_idx = temp_body[last_start_quote_idx..-1].index(/\[\/quote\]/)
      break if next_end_quote_idx.nil?
      next_end_quote_idx += last_start_quote_idx + 7

      temp_body[last_start_quote_idx..next_end_quote_idx] = temp_body[last_start_quote_idx..next_end_quote_idx].gsub(/\[quote(.*?)\]((.|\n)*?)\[\/quote\]/) do |found_match|
        token = unique_token(temp_body)
        @quotes << [token, found_match]
        token
      end
    end

    temp_body = unwrap_quotes(temp_body, max_nested_level: 3)

    self.body = temp_body
  end

  def unwrap_quotes(text, nested_idx=0, max_nested_level:)
    text.gsub(/quotetoken[a-z]{10}/).each do |found_token|
      quote_to_unwrap = @quotes.select { |(token, quote)| token == found_token }.first[1]
      if nested_idx < max_nested_level
        unwrap_quotes(quote_to_unwrap, nested_idx + 1, max_nested_level: max_nested_level)
      else
        quote_author = quote_to_unwrap[/\[quote(.*?)\]/][7..-2]
        quote_from = quote_author.presence ? " from #{quote_author}" : ""
        "*\\[quote#{quote_from}]*"
      end
    end
  end

  def unique_token(text)
    loop do
      new_token = "quotetoken" + ('a'..'z').to_a.sample(10).join("")
      break new_token unless text.include?(new_token)
    end
  end

end
