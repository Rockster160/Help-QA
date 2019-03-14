module SpamCheck
  extend ActiveSupport::Concern

  def body_contains_any?(text, words)
    words.any? { |word| text.downcase.include?(word) }
  end

  def sounds_fake?(text)
    fake_words = ["href=", "<a", "[url="]

    body_contains_any?(text, fake_words)
  end

  def blacklisted_text?(text)
    blacklist = ["__media__"]

    body_contains_any?(text, blacklist)
  end

  def sounds_like_cash_cow?(text)
    cash_cow_words = ["cash loans", "online casino", "creditloans", "poker online", "onlinebuy"]

    body_contains_any?(text, cash_cow_words)
  end

  def sounds_like_ad?(text)
    spam_words = ["my web", "look at my page", "free trial", "my blog", "blog post", "my homepage", "my page", "%anchor_text", "my site", "poker", "web blog", "yukhoki"]

    body_contains_any?(text, spam_words)
  end

  def includes_link?(text)
    !(text =~ /https?\:\/\//).nil?
  end

  def sounds_like_spam?(text)
    sounds_fake?(text) || sounds_like_cash_cow?(text) || sounds_like_ad?(text) || includes_link?(text)
  end

  included do
    def blacklisted_text?
      self.class.blacklisted_text?(body)
    end

    def sounds_like_cash_cow?
      self.class.sounds_like_cash_cow?(body)
    end

    def sounds_like_ad?
      self.class.sounds_like_ad?(body)
    end

    def sounds_fake?
      self.class.sounds_fake?(body)
    end

    def sounds_like_spam?
      return false if author.replies.where.not(id: id).any? || author.posts.where.not(id: id).any?

      self.class.sounds_like_spam?(body)
    end
  end
end
