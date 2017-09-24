module MarkdownHelper
  def markdown(should_render_html: false, poll_post_id: nil, posted_by_user: nil, &block)
    @markdown_posted_by_user = posted_by_user
    @markdown_post = Post.find_by(id: poll_post_id)
    @markdown_text = yield.to_s.dup

    escape_html_characters(should_render_html)
    escape_markdown_characters
    invite_tagged_users
    parse_markdown
    parse_directive_quotes
    parse_directive_poll if @markdown_post.present?
    clean_up_html

    # NOTE: This code is used in the FAQ - If it's ever changed, verify that changes did not break that page.
    @markdown_text.html_safe
  end

  def clean_up_html
    @markdown_text[0] = "" while @markdown_text[0] =~ / \n\r/ # Remove New Lines before post.
    @markdown_text[-1] = "" while @markdown_text[-1] =~ / \n\r/ # Remove New Lines after post.
    if @markdown_text.index(/<p>[ |\n|\r]*?<\/p>/) == 0
      @markdown_text[0..@markdown_text.index("</p>") + 3] = ""
    end
  end

  def parse_directive_poll
    # When Post is updated, need to make sure to find the poll and
    # Should have 2 different methods. One that gets run when the post is created/updated, which looks for options
    # When editing a post, should generate it's own markdown by adding the options to the [poll: ] tag
    # The other method should only parse based on [poll#post_id]
    # @markdown_text.sub!(/\[poll(.*?)\]/) do |found_match|
    #   poll_args = $1
    #
    #   if poll_args =~ /^#\d+/
    #     render_poll(poll_args.gsub(/[^0-9]/, ""))
    #   else
    #     new_poll = @markdown_post.build_poll
    #     poll_options = poll_args.split(",").map(&:squish).map(&:presence).compact
    #
    #     if poll_options.length >= 2
    #       return unless new_poll.save
    #
    #       poll_options.each do |poll_option_text|
    #         new_poll.options.create(option_text: )
    #       end
    #     else
    #     end
    #   end
    # end
  end

  def render_poll(post_id)
    return unless @markdown_post.present? && @markdown_post.id.to_i == post_id.to_i
    poll = @markdown_post.poll
    return if poll.nil?
    # render partial as template with poll as local
  end

  def parse_directive_quotes
    loop do
      last_start_quote_idx = @markdown_text.rindex(/\[quote(.*?)\]/)
      break if last_start_quote_idx.nil?
      next_end_quote_idx = @markdown_text[last_start_quote_idx..-1].index(/\[\/quote\]/)
      break if next_end_quote_idx.nil?
      next_end_quote_idx += last_start_quote_idx + 7

      @markdown_text[last_start_quote_idx..next_end_quote_idx] = @markdown_text[last_start_quote_idx..next_end_quote_idx].gsub(/\[quote(.*?)\]((.|\n)*?)\[\/quote\]/) do
        quote_string = $1.present? ? "<strong>#{$1.squish} wrote:</strong><br>" : ""
        "</p><quote><p>#{quote_string}#{$2}</p></quote><p>"
      end
    end
  end

  def escape_html_characters(should_render_html)
    @markdown_text.gsub!("&", "&amp;") # Escape ALL & - prevent Unicode injection / unexpected character behavior
    @markdown_text.gsub!("<script", "&lt;script") # Escape <script> Tags

    unless should_render_html
      @markdown_text.gsub!("<", "&lt;")
      @markdown_text = "<p>#{@markdown_text}</p>"
      @markdown_text.gsub!("\n", "</p><p>")
      @markdown_text.gsub!("\r", "")
    end
  end

  def escape_markdown_characters
    @markdown_text.gsub!("\\@", "&#64;") # @
    @markdown_text.gsub!("\\\\", "&#92;") # \
    @markdown_text.gsub!("\\\`\`\`", "&#96;&#96;&#96;") #  ```
    @markdown_text.gsub!("\\\[", "&#91;") # [
    @markdown_text.gsub!("\\\*", "&#42;") # *
    @markdown_text.gsub!("\\\`", "&#96;") # `
    @markdown_text.gsub!("\\\_", "&#95;") # _
    @markdown_text.gsub!("\\\~", "&#126;") # ~
  end

  def invite_tagged_users
    return unless @markdown_posted_by_user.present?
    @markdown_text.gsub!(/@([^ \`\@]+)/) do |username_tag|
      tagged_user = User.by_username($1)
      if tagged_user.present? && (tagged_user.friends?(@markdown_posted_by_user) || tagged_user == @markdown_posted_by_user)
        leftovers = username_tag.gsub(/[@#{Regexp.escape(tagged_user.username)}]/i, "")
        "<a href=\"#{user_path(tagged_user)}\" class=\"tagged-user\">@#{tagged_user.username}</a>#{leftovers}"
      else
        username_tag
      end
    end
  end

  def parse_markdown
    @markdown_text.gsub!(/\`\`\`(.|\n)*?\`\`\`/) do |found_match|
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
      inner_text.gsub!("</p><p>", "<br>")
      "<blockquote><div class=\"wrapper\">#{inner_text}</div></blockquote>"
    end
    parse_markdown_character_with("*") { "<strong>$1</strong>" }
    parse_markdown_character_with("`") { "<code>$1</code>" }
    parse_markdown_character_with("_") { "<i>$1</i>" }
    parse_markdown_character_with("~") { "<strike>$1</strike>" }
  end

  def parse_markdown_character_with(char, &string_with_special_replace)
    @markdown_text.gsub!(regex_for_wrapping_character(char)) do |found_match|
      " " + string_with_special_replace.call.gsub("$1", "#{$1}")
    end
  end

  def regex_for_wrapping_character(character)
    regex_safe_character = Regexp.escape(character)
    not_space = "[^ ]"
    at_least_one_character_group = "((.|\n)*?)"

    / #{regex_safe_character}(#{not_space}.*?#{not_space}?)#{regex_safe_character}/m
  end
end
