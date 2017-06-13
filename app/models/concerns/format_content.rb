module FormatContent
  extend ActiveSupport::Concern

  def format_content(content_text, options={})
    temp_content = content_text
    temp_content = "<p>#{temp_content}</p>"
    temp_content.gsub!(/\n[\W|\r]*?\n/, "</p><p>")
    temp_content.gsub!(/\n/, "<br>")
    # Add options to filter which things are/aren't allowed
    # Options for EITHER inclusive or exclusive
    #  -- Markdown (Bold, Italics, Strike)
    #  -- Code Blocks / Lines
    #  -- Quotes
    #  -- Polls
    #  -- Videos
    #  -- Images
    #  -- Links
    # Prettify links, embed images, do supported markdown, etc
    # SANITIZE HTML TAGS!
    temp_content.squish.html_safe
  end

end
