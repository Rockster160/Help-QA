module SpamCheck
  extend ActiveSupport::Concern

  def body_contains_any?(text, words)
    words.any? { |word| text.downcase.include?(word) }
  end

  def sounds_fake?(text)
    fake_words = ["href=", "<a", "[url="]
    body_contains_any?(text, fake_words)
  end

  def sounds_like_cash_cow?(text)
    cash_cow_words = ["cash loans", "online casino", "creditloans", "poker online", "onlinebuy"]
    body_contains_any?(text, cash_cow_words)
  end

  def sounds_like_ad?(text)
    spam_words = ["my web", "look at my page", "free trial", "my blog", "blog post", "my homepage", "my page", "%anchor_text", "my site", "poker", "web blog", "yukhoki"]
    body_contains_any?(text, spam_words)
  end

  def sounds_like_spam?(text)
    sounds_fake?(text) || sounds_like_cash_cow?(text) || sounds_like_ad?(text)
  end
end
