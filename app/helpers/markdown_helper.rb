module MarkdownHelper
  def markdown(html_safe=false, &block)
    # When using markdown, only apply if the characters are tightly wrapped.
    # *this works!* *But this does not *
    # Do NOT grab any tags that come after a \
    # If html_safe is false, escape HTML codes
    # ALWAYS disable script codes
    # Do NOT style empty blocks EG: **, __, ``, etc...
    yield
    # NOTE: This code is used in the FAQ - If it's every changed, verify that changes did not break that page.
    nil
  end
end
