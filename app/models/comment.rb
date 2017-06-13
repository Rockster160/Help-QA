# == Schema Information
#
# Table name: comments
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

class Comment < ApplicationRecord
  include FormatContent

  belongs_to :post
  belongs_to :author, class_name: "User"
  has_many :tags, through: :post

  def content(options={})
    format_content(body, options)
  end

  def username
    if posted_anonymously?
      "Anonymous"
    else
      author.username
    end
  end

  def avatar
    if posted_anonymously?
      identicon_src(author.ip_address)
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

  def identicon_src(ip)
    base64_identicon = RubyIdenticon.create_base64(ip, square_size: 5, border_size: 0, grid_size: 7, background_color: 0xffffffff)
    "data:image/png;base64,#{base64_identicon}"
  end

end
