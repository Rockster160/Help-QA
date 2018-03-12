module MetaHelper
  def meta_title(str, include_name: true)
    content_for(:title) { CGI.escapeHTML(str).html_safe }
  end

  def meta_description(description)
    content_for(:description) { CGI.escapeHTML(description).html_safe }
  end

  def meta_no_index
    content_for(:meta) { '<meta name="robots" content="noindex, nofollow">'.html_safe }
  end
end
