module MetaHelper
  def meta_title(str, include_name: true)
    content_for(:title) { str.html_safe }
  end

  def meta_description(description)
    content_for(:description) { description.html_safe }
  end

  def meta_no_index
    content_for(:meta) { '<meta name="robots" content="noindex, nofollow">'.html_safe }
  end
end
