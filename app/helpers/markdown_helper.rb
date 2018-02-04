module MarkdownHelper
  def censor_text(text)
    adult_word_regex = Tag.adult_words.map { |word| Regexp.quote(word) }.join("|")

    text.gsub(/\b(#{adult_word_regex})\b/i) do |found|
      "*" * found.length
    end
  end

  def markdown(only: nil, except: [], with: [], render_html: false, poll_post: nil, posted_by_user: nil, &block)
    only = [only].flatten if only.is_a?(Array) # We want `only` to be `nil` if it wasn't explicitly set.
    except = [except].flatten

    # Non-default options: [:inline_previews, :ignore_previews]
    default_markdown_options = [:quote, :tags, :bold, :italic, :strike, :code, :codeblock, :poll, :allow_link_previews]
    default_markdown_options = only if only.is_a?(Array)
    default_markdown_options -= except
    default_markdown_options += with
    @markdown_options = Hash[default_markdown_options.product([true])]

    user = posted_by_user
    post = poll_post
    text = yield.to_s.dup
    return text.html_safe if posted_by_user.try(:helpbot?)

    text = escape_html_characters(text, render_html: render_html)
    text = escape_escaped_markdown_characters(text)
    text = filter_nested_quotes(text, max_nest_level: 3)
    text = escape_escaped_markdown_characters(text)
    text = parse_directive_quotes(text)
    text = invite_tagged_users(text) if @markdown_options[:tags]
    text = link_previews(text) unless @markdown_options[:ignore_previews]
    text = parse_markdown(text)
    text = text.gsub(/ \** /) { |found_match| " #{escape_markdown_characters_in_string(found_match)} " }
    text = parse_directive_poll(text, post: post) if post.present? && @markdown_options[:poll]
    text = censor_language(text)
    text = clean_up_html(text)

    # NOTE: This code is used in the FAQ - If it's ever changed, verify that changes did not break that page.
    text.html_safe
  end

  def clean_up_html(text)
    text[0] = "" while text[0] =~ /[ \n\r]/ # Remove white space before post.
    text[-1] = "" while text[-1] =~ /[ \n\r]/ # Remove white space after post.
    text[0..text.index("</p>") + 3] = "" while text.index(/<p>[ |\n|\r]*?<\/p>/).try(:zero?) # Remove empty paragraph tags before post.
    text
  end

  def censor_language(text)
    adult_word_regex = Tag.adult_words.map { |word| Regexp.quote(word) }.join("|")

    text = text.gsub(/\>.*?\</) do |found|
      safe_words = found.gsub(/\b(#{adult_word_regex})\b/i) do |found|
        "<span class=\"profane-wrapper\"><span class=\"safe\" title=\"#{found}\">#{'*'*found.length}</span><span class=\"unsafe\">#{found}</span></span>"
      end
      "#{safe_words}"
    end
    text
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
        quote_author = escape_markdown_characters_in_string($1.squish)

        quote_string = quote_author.present? ? "<strong>#{quote_author} wrote:</strong><br>" : ""
        "</p><quote><p>#{quote_string}#{quote_text}</p></quote><p>"
      end
    end
    text
  end

  def escape_html_tags(text)
    text = text.gsub("&", "&amp;")
    text = text.gsub("<", "&lt;")
  end

  def escape_html_characters(text, render_html: false)
    text = text.gsub("&", "&amp;") # Escape ALL & - prevent Unicode injection / unexpected character behavior
    text = text.gsub("<script", "&lt;script") # Escape <script> Tags

    unless render_html
      text = text.gsub("<", "&lt;")
      text = "<p>#{text}</p>"
      text = text.gsub("\r", "")
      text = text.gsub("\n\n", "</p><p>")
      text = text.gsub("\n", "<br>")
    end
    text
  end

  def escape_escaped_markdown_characters(text)
    # Shrug loses left arm because it's a \_ which is interpreted as escaping an underscore.
    text = text.gsub("\\@", "&#64;") # @
    text = text.gsub("\\\\", "&#92;") # \
    text = text.gsub("\\\`\`\`", "&#96;&#96;&#96;") #  ```
    text = text.gsub("\\\[", "&#91;") # [
    text = text.gsub("\\\*", "&#42;") # *
    text = text.gsub("\\\`", "&#96;") # `
    text = text.gsub("\\\_", "&#95;") # _
    text = text.gsub("\\\~", "&#126;") # ~
  end

  def escape_markdown_characters_in_string(str)
    str = str.gsub("@", "&#64;") # @
    str = str.gsub("\\", "&#92;") # \
    str = str.gsub("[", "&#91;") # [
    str = str.gsub("*", "&#42;") # *
    str = str.gsub("`", "&#96;") # `
    str = str.gsub("_", "&#95;") # _
    str = str.gsub("~", "&#126;") # ~
    str = str.gsub(":", "&#58;")
    str = str.gsub(".", "&#46;")
  end

  def invite_tagged_users(text)
    text = text.gsub(/@\[([^ \`\@]+):(\d+)\]/) do |username_tag|
      user_id = $2
      tagged_user = User.find_by(id: user_id)

      if tagged_user.present?
        escaped_username = escape_markdown_characters_in_string(tagged_user.username)
        "<a href=\"#{user_path(user_id)}-#{tagged_user.slug}\" class=\"tagged-user\">&#64;#{escaped_username}</a>"
      else
        "@#{$1}"
      end
    end
  end

  def parse_markdown(text)
    text = text.gsub(/([ >\n\r])(\**)([ <\n\r])/) { |found_match| "#{$1}#{escape_markdown_characters_in_string($2)}#{$3}" }
    text = text.gsub(/<a(.*?)<\/a>/) do |found_match|
      "<a#{escape_markdown_characters_in_string($1)}</a>"
    end
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

  def find_links_in_text(text)
    extension_blacklist = [:to]
    domain_blacklist = [:idolosol]
    # These are exact matches, so something like sub.idolosol would not be counted.
    to_replace = []
    scan_idx = 0
    text.scan(url_regex).each_with_index do |link_parts, idx|
      protocol, domain, tld, port, path, params, anchor = link_parts
      next if extension_blacklist.include?(tld)
      next if domain_blacklist.include?(domain)
      link = link_parts.compact.join("")
      punctuation_characters = /[\.\?\! \n\r,'"’“”]/
      invalid_pre_char_count = 0
      invalid_post_char_count = 0

      while link[0] =~ punctuation_characters # Remove punctuation before url.
        invalid_pre_char_count += 1
        link[0] = ""
      end
      while link[-1] =~ punctuation_characters # Remove punctuation after url.
        invalid_post_char_count += 1
        link[-1] = ""
      end

      if scan_idx == 0
        before_text = ""
        split_text = text.dup
      else
        before_text = text[0..scan_idx-1 + invalid_pre_char_count]
        split_text = text[scan_idx..-1]
      end

      first_idx = scan_idx + split_text.index(link)
      last_idx = first_idx + link.length - 1
      pre_char = text[first_idx - 1]
      post_char = text[last_idx + 1]
      scan_idx = last_idx

      meta_data = retrieve_meta_data_for_url(link)
      looks_youtube = domain.include?("youtu")
      looks_vimeo = domain.include?("vimeo")
      has_path_extension = path.to_s[/\.\w{2,4}$/].present?
      should_parse = looks_youtube || looks_vimeo || has_path_extension

      to_replace << {
        url: link,
        start_idx: first_idx,
        show_preview: pre_char == "[" && post_char == "]" && @markdown_options[:allow_link_previews],
        meta_data: meta_data,
        inline: @markdown_options[:inline_previews] || meta_data&.dig(:inline),
        escaped: pre_char == "\\",
        invalid: meta_data&.dig(:invalid_url),
        should_parse: should_parse
        # url
        # request_url
        # favicon
        # title
        # description
        # inline
        # should_iframe
        # video_url
        # image_url
        # only_image
        # invalid_url
      }
    end
    to_replace
  end

  def link_previews(text)
    add_to_text = []
    current_idx = 0

    find_links_in_text(text).each do |link_hash|
      before_text, split_text = text[0..current_idx-1], text[current_idx..-1]
      if current_idx == 0
        before_text = ""
        split_text = text.dup
      end

      link = link_hash[:url]
      replace_link = link_hash[:show_preview] ? "[#{link}]" : link
      request_url = link_hash[:request_url] || link[/^http|\/\//i].nil? ? "http://#{link.gsub(/^\/*/, '')}" : link
      meta_data = link_hash[:meta_data]

      new_link = if link =~ Devise::email_regexp
        "<a rel=\"nofollow\" target=\"_blank\" href=\"mailto:#{link}\">#{truncate(link, length: 50, omission: "...")}</a>"
      elsif link_hash[:invalid]
        link
      elsif (link_hash[:show_preview] || link_hash[:inline]) && !link_hash[:escaped]
        if meta_data.nil?
          # Offload to JS to speed up page load time
          "<a rel=\"nofollow\" target=\"_blank\" href=\"#{request_url}\" data-original-url=\"#{link}\" data-load-preview>[#{truncate(link, length: 50, omission: "...")}]</a>"
        elsif link_hash[:inline]
          render_link_from_meta_data(meta_data)
        else
          add_to_text << render_link_from_meta_data(meta_data)
          "<a rel=\"nofollow\" target=\"_blank\" href=\"#{request_url}\">[#{meta_data[:title]}]</a>"
        end
      elsif link_hash[:escaped] || !link_hash[:should_parse]
        replace_link = "\\#{link}" if link_hash[:escaped]
        "<a rel=\"nofollow\" target=\"_blank\" href=\"#{request_url}\">#{truncate(link, length: 50, omission: "...")}</a>"
      else
        if meta_data.nil?
          # Offload to JS to speed up page load time
          "<a rel=\"nofollow\" target=\"_blank\" href=\"#{request_url}\" data-original-url=\"#{link}\" data-load-preview=\"no\">#{truncate(link, length: 50, omission: "...")}</a>"
        else
          "<a rel=\"nofollow\" target=\"_blank\" href=\"#{request_url}\">#{truncate(link, length: 50, omission: "...")}</a>"
        end
      end

      link_idx = split_text.index(replace_link)
      new_after_text = split_text.sub(replace_link, new_link)
      text = before_text + split_text.sub(replace_link, new_link)
      current_idx = before_text.length + link_idx + new_link.length
    end

    "#{text}#{add_to_text.uniq.join(" ")}"
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
    # TODO: Seems to be a bug here- when there are too many nested quotes and text before and after quote.
    #   End quote seems to be improperly removed.
    text.gsub(/quotetoken[a-z]{10}/).each do |found_token|
      quote_to_unwrap = quotes.select { |(token, quote)| token == found_token }.first[1]
      if depth < max_nest_level
        unwrap_quotes(quote_to_unwrap, depth: depth + 1, quotes: quotes, max_nest_level: max_nest_level)
      else
        quote_author = quote_to_unwrap[/\[quote(.*?)\]/][7..-2]
        quote_from = quote_author.presence ? " from #{escape_markdown_characters_in_string(quote_author)}" : ""
        "_*\\[quote#{quote_from}]*_\n"
      end
    end
  end

  def url_regex
    # https://perishablepress.com/stop-using-unsafe-characters-in-urls/#character-encoding-chart
    @url_regex ||= begin
      # Regex groups
      alphanumeric = "a-z0-9"
      specialChars = "$-_+!*'(),;".split("").map { |char| "\\#{char}" }.join("")
      paramChars = "&%=[]".split("").map { |char| "\\#{char}" }.join("")
      alphaspecial = "#{alphanumeric}#{specialChars}"

      # Url Parts
      protocol = "(https?:\\/\\/)?"
      # OPTIONAL - http or https followed by :// - https://
      domain = "((?:[a-z][#{alphaspecial}]{0,256}\\.)+)" # Includes subdomains and www
      # REQUIRED - At least one grouping of permitted characters of size 2-256 followed by a period - sup.foo.domain.
      tld = "([a-z][#{alphaspecial}]{1,6})"
      # REQUIRED - One grouping of permitted characters of size 2-6 - .com
      port = "(\\:[\\d]{2,4})?"
      # OPTIONAL - colon followed by 2-4 digits - :1234
      path = "([\\/\\:#{alphaspecial}\\.]+)*"
      # OPTIONAL - Any number (including 0) of groups of a forward slash / followed by any number of permitted characters - /this/that/foo/bar
      params = "(\\/?\\?[\\:#{alphaspecial}#{paramChars}\\.]+)?"
      # OPTIONAL - A ? followed by any number of characters, including the param types
      anchor = "(\\#[\\:#{alphaspecial}#{paramChars}\\.]+)?"
      # OPTIONAL - A # followed by any number of characters, including the param types
      # /(https?:\/\/)?((?:[a-z][a-z0-9\$\-\_\+\!\*\'\(\)\,\;\:]{0,256}\.)+)([a-z][a-z0-9\$\-\_\+\!\*\'\(\)\,\;\:]{1,6})(:[\d]{2,4})?([\/a-z0-9\$\-\_\+\!\*\'\(\)\,\;\:\.]+)*(\/?\?[a-z0-9\$\-\_\+\!\*\'\(\)\,\;\:\&\%\=\[\]\.]+)?(\#[a-z0-9\$\-\_\+\!\*\'\(\)\,\;\:\&\%\=\[\]\.]+)?/ig
      /#{protocol}#{domain}#{tld}#{port}#{path}#{params}#{anchor}/i
    end
  end
end

# 1 protocol (https?:\/\/)?
# 2 domain   ([a-z][a-z0-9\$\-\_\+\!\*\'\(\)\,\;]{1,256}\.)+
# 3 tld      ([a-z][a-z0-9\$\-\_\+\!\*\'\(\)\,\;]{1,6})
# 4 port     (:[\d]{2,4})?
# 5 path     ([\/a-z0-9\$\-\_\+\!\*\'\(\)\,\;\.]+)*
# 6 params   (\/?\?[a-z0-9\$\-\_\+\!\*\'\(\)\,\;\&\%\=\[\]\.]+)?
# 7 anchor   (\#[a-z0-9\$\-\_\+\!\*\'\(\)\,\;\&\%\=\[\]\.]+)?
