module UrlHelper
  def url_for(path)
    url_opts = ActionMailer::Base.default_url_options
    port_str = url_opts[:host] == "localhost" ? ":#{url_opts[:port]}" : ""
    "#{url_opts[:protocol] || 'http'}://#{url_opts[:host]}#{port_str}#{path}"
  end

  def link_to(text, link_url, passed_root: nil)
    link_url[0] = "" while link_url[0] == "/"
    passed_root[-1] = "" while passed_root[-1] == "/" if passed_root.present?
    "<a href=\"#{[passed_root, link_url].compact.join('/')}\">#{text}</a>"
  end

  def add_params_to_urls_in_message(message, additional_params)
    new_message = message
    URI.extract(message).each do |found_url|
      uri = URI(found_url)
      new_query_uri = URI.decode_www_form(uri.query || '')
      additional_params.each do |add_key, add_val|
        new_query_uri << [add_key, add_val]
      end
      uri.query = URI.encode_www_form(new_query_uri)
      new_message.gsub(found_url, uri.to_s)
    end
    new_message
  end
end
