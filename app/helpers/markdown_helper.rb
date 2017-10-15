module MarkdownHelper
  def censor_text(text)
    adult_word_regex = Tag.adult_words.map { |word| Regexp.quote(word) }.join("|")

    text.gsub(/\b(#{adult_word_regex})\b/i) do |found|
      "*" * found.length
    end
  end

  def markdown(only: nil, except: [], render_html: false, poll_post_id: nil, posted_by_user: nil, &block)

    only = [only].flatten
    except = [except].flatten

    default_markdown_options = [:quote, :tags, :bold, :italic, :strike, :code, :codeblock, :poll, :emoji]
    default_markdown_options = only if only.any?
    default_markdown_options -= except
    @markdown_options = Hash[default_markdown_options.product([true])]

    user = posted_by_user
    post = Post.find_by(id: poll_post_id)
    text = yield.to_s.dup
    return text.html_safe if posted_by_user.try(:helpbot?)

    text = escape_html_characters(text, render_html: render_html)
    text = escape_markdown_characters(text)
    text = filter_nested_quotes(text, max_nest_level: 3)
    text = escape_markdown_characters(text)
    text = invite_tagged_users(text, author: user) if @markdown_options[:tags]
    text = parse_markdown(text)
    text = parse_directive_quotes(text)
    text = parse_directive_poll(text, post: post) if post.present? && @markdown_options[:poll]
    text = parse_emoji(text) if @markdown_options[:emoji]
    text = censor_language(text) if current_user.try(:settings).try(:censor_inappropriate_language)
    text = clean_up_html(text)

    # NOTE: This code is used in the FAQ - If it's ever changed, verify that changes did not break that page.
    text.html_safe
  end

  def clean_up_html(text)
    text[0] = "" while text[0] =~ /[ \n\r]/ # Remove New Lines before post.
    text[-1] = "" while text[-1] =~ /[ \n\r]/ # Remove New Lines after post.
    text[0..text.index("</p>") + 3] = "" while text.index(/<p>[ |\n|\r]*?<\/p>/).try(:zero?) # Remove empty paragraph tags before post.
    text
  end

  def censor_language(text)
    adult_word_regex = Tag.adult_words.map { |word| Regexp.quote(word) }.join("|")

    text.gsub(/\b(#{adult_word_regex})\b/i) do |found|
      "<span title=\"#{found}\">#{'*'*found.length}</span>"
    end
  end

  def parse_emoji(text)
    not_between_carrots_regex = /[^<>]+(?![^<]*>)/
    emoji_regex = /([^a-zA-Z0-9\\]?)\:([^ \n]+?)\:/

    text.gsub(not_between_carrots_regex) do |found_match|
      found_match.gsub(emoji_regex) do |found_emoji|
        "#{$1}#{emoji($2)}"
      end
    end
  end

  def parse_directive_poll(text, post:)
    text.sub("[poll]") do
      PostsController.render(template: 'posts/poll', layout: false, assigns: { post: post, user: current_user })
    end
  end

  def parse_directive_quotes(text)
    loop do
      last_start_quote_idx = text.rindex(/\[quote(.*?)\]/)
      break if last_start_quote_idx.nil?
      next_end_quote_idx = text[last_start_quote_idx..-1].index(/\[\/quote\]/)
      break if next_end_quote_idx.nil?
      next_end_quote_idx += last_start_quote_idx + 7

      text[last_start_quote_idx..next_end_quote_idx] = text[last_start_quote_idx..next_end_quote_idx].gsub(/\[quote(.*?)\]((.|\n)*?)\[\/quote\]/) do
        quote_text = $2
        quote_author = $1.squish.gsub(":", "&#58;")

        quote_string = quote_author.present? ? "<strong>#{quote_author} wrote:</strong><br>" : ""
        "</p><quote><p>#{quote_string}#{quote_text}</p></quote><p>"
      end
    end
    text
  end

  def escape_html_characters(text, render_html: false)
    text = text.gsub("&", "&amp;") # Escape ALL & - prevent Unicode injection / unexpected character behavior
    text = text.gsub("<script", "&lt;script") # Escape <script> Tags

    unless render_html
      text = text.gsub("<", "&lt;")
      text = "<p>#{text}</p>"
      text = text.gsub("\n", "</p><p>")
      text = text.gsub("\r", "")
    end
    text
  end

  def escape_markdown_characters(text)
    text = text.gsub("\\@", "&#64;") # @
    text = text.gsub("\\\\", "&#92;") # \
    text = text.gsub("\\\`\`\`", "&#96;&#96;&#96;") #  ```
    text = text.gsub("\\\[", "&#91;") # [
    text = text.gsub("\\\*", "&#42;") # *
    text = text.gsub("\\\`", "&#96;") # `
    text = text.gsub("\\\_", "&#95;") # _
    text = text.gsub("\\\~", "&#126;") # ~
  end

  def invite_tagged_users(text, author:)
    return text unless author.present?
    text.gsub(/@([^ \`\@]+)/) do |username_tag|
      username = $1.gsub(/\<.*?\>/, "")
      tagged_user = User.by_username(username)
      if tagged_user.present? && (tagged_user.friends?(author) || tagged_user == author)
        leftovers = username_tag.gsub(/[@#{Regexp.escape(tagged_user.username)}]/i, "")
        "<a href=\"#{user_path(tagged_user)}\" class=\"tagged-user\">@#{tagged_user.username.gsub(':', '&#58;')}</a>#{leftovers}"
      else
        username_tag
      end
    end
  end

  def parse_markdown(text)
    text = text.gsub(/\`\`\`(.|\n)*?\`\`\`/) do |found_match|
      inner_text = found_match[3..-4]
      # Using loop because `gsub` tries to look at each line individually, which removes all white space at the beginning of other lines.
      loop do
        break unless inner_text[0] =~ /(\n|\r)/
        inner_text[0] = ""
      end
      loop do
        break unless inner_text[-1] =~ /(\n|\r| )/
        inner_text[-1] = ""
      end
      inner_text.gsub("</p><p>", "<br>")
      "<blockquote><div class=\"wrapper\">#{inner_text}</div></blockquote>"
    end if @markdown_options[:codeblock]

    text = parse_markdown_character_with("*", text) { "<strong>$1</strong>" }  if @markdown_options[:bold]
    text = parse_markdown_character_with("`", text) { "<code>$1</code>" }  if @markdown_options[:code]
    text = parse_markdown_character_with("_", text) { "<i>$1</i>" }  if @markdown_options[:italic]
    text = parse_markdown_character_with("~", text) { "<strike>$1</strike>" }  if @markdown_options[:strike]
    text
  end

  def parse_markdown_character_with(char, text, &string_with_special_replace)
    text.gsub(regex_for_wrapping_character(char)) do |found_match|
      $1 + string_with_special_replace.call.gsub("$1", "#{$2}")
    end
  end

  def regex_for_wrapping_character(character)
    regex_safe_character = Regexp.escape(character)
    not_space = "[^ ]"
    at_least_one_character_group = "((.|\n)*?)"

    /(\W|\*|\`|\_|\~)#{regex_safe_character}(#{not_space}.*?#{not_space}?)#{regex_safe_character}/m
  end

  def generate_unique_token(text)
    loop do
      new_token = "quotetoken" + ('a'..'z').to_a.sample(10).join("")
      break new_token unless text.include?(new_token)
    end
  end

  def filter_nested_quotes(text, max_nest_level:)
    text = text.dup
    quotes = []

    loop do
      last_start_quote_idx = text.rindex(/\[quote(.*?)\]/)
      break if last_start_quote_idx.nil?
      next_end_quote_idx = text[last_start_quote_idx..-1].index(/\[\/quote\]/)
      break if next_end_quote_idx.nil?
      next_end_quote_idx += last_start_quote_idx + 7

      text[last_start_quote_idx..next_end_quote_idx] = text[last_start_quote_idx..next_end_quote_idx].gsub(/\[quote(.*?)\]((.|\n)*?)\[\/quote\]/) do |found_match|
        token = generate_unique_token(text)
        quotes << [token, found_match]
        token
      end
    end

    unwrap_quotes(text, quotes: quotes, max_nest_level: max_nest_level)
  end

  def unwrap_quotes(text, depth: 0, quotes:, max_nest_level:)
    text.gsub(/quotetoken[a-z]{10}/).each do |found_token|
      quote_to_unwrap = quotes.select { |(token, quote)| token == found_token }.first[1]
      if depth < max_nest_level
        unwrap_quotes(quote_to_unwrap, depth: depth + 1, quotes: quotes, max_nest_level: max_nest_level)
      else
        quote_author = quote_to_unwrap[/\[quote(.*?)\]/][7..-2]
        quote_from = quote_author.presence ? " from #{quote_author.gsub(':', '&#58;')}" : ""
        "_*\\[quote#{quote_from}]*_\n"
      end
    end
  end
end
