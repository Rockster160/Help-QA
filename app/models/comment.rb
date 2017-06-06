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

  belongs_to :post
  belongs_to :author, class_name: "User"

  def content
    temp_body = body
    temp_body = "<p>#{temp_body}</p>"
    temp_body.gsub!(/\n[\W|\r]*?\n/, "</p><p>")
    temp_body.gsub!(/\n/, "<br>")
    # Prettify links, embed images, do supported markdown, etc
    # SANITIZE HTML TAGS!
    temp_body.squish.html_safe
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

end
