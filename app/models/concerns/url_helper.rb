module UrlHelper
  def url_for(path)
    url_opts = ActionMailer::Base.default_url_options
    port_str = url_opts[:host] == "localhost" ? ":#{url_opts[:port]}" : ""
    "#{url_opts[:protocol] || 'http'}://#{url_opts[:host]}#{port_str}#{path}"
  end

  def link_to(text, link_url)
    "<a href=\"#{link_url}\">#{text}</a>"
  end
end
