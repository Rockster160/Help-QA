module UrlHelper
  def url_for(path)
    url_opts = ActionMailer::Base.default_url_options
    port_str = url_opts[:host] == "localhost" ? ":#{url_opts[:port]}" : ""
    "#{url_opts[:protocol] || 'http'}://#{url_opts[:host]}#{port_str}#{path}"
  end

  def link_to(text, link_url, passed_root: nil)
    link_url[0] = "" while link_url[0] == "/"
    passed_root[-1] = "" while passed_root[-1] == "/"
    "<a href=\"#{[passed_root, link_url].compact.join('/')}\">#{text}</a>"
  end
end
