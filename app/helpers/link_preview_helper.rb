module LinkPreviewHelper

  def generate_previews_for_urls(clear: false)
    [params[:urls]].flatten.compact.uniq.map do |raw_url|
      generate_link_preview_for_url(raw_url, clear: clear, generate_if_nil: true)
    end.compact
  end

  def generate_link_preview_for_url(raw_url, clear: false, generate_if_nil: false)
    raw_url = raw_url.gsub("&amp;", "&") # Hack because JS persistently escapes ampersands
    raw_url = raw_url.downcase
    return if raw_url[/^\w+(\.){2,}\w+$/] # Skip url if there is 2 periods
    url = "http://#{raw_url.gsub(/^\/*/, '')}" unless raw_url.starts_with?("http")
    url ||= raw_url

    Rails.cache.delete(url) if clear
    return if Rails.cache.read(url).nil? && !generate_if_nil
    meta_data = Rails.cache.fetch(url) do
      puts "Running Cache Fetch for: #{url}".colorize(:yellow)
      res = RestClient.get(url) rescue nil
      next {} if res.nil?

      doc = Nokogiri::HTML(res.body)
      only_image = MIME::Types.type_for(url).first.try(:content_type)&.starts_with?("image")

      tags = {}
      doc.search("meta").each do |meta_tag|
        meta_type = meta_tag["property"].presence || meta_tag["name"].presence
        next unless meta_type.present?

        tags[meta_type] = meta_tag["content"]
      end
      favicon_element = doc.xpath('//link[@rel="shortcut icon"]').first

      video_url = tags["twitter:player"]
      iframe_video_url = video_url if video_url.present? && (video_url.include?("player.vimeo") || video_url.include?("youtube.com/embed"))
      iframe_video_url ||= url if url.present? && (url.include?("player.vimeo") || url.include?("youtube.com/embed"))
      iframe_video_url ||= "https://player.vimeo.com/video/#{url[/\d+$/]}" if url =~ /vimeo.com\/\d+$/

      meta_data = {
        iframe_video_url: iframe_video_url,
        video_url: iframe_video_url.presence || video_url.presence,
        only_image: only_image,
        url: url,
        favicon: favicon_element.present? ? favicon_element["href"] : nil,
        title: doc.title,
        # description: tags["twitter:description"].presence || tags["twitter:title"].presence || tags["og:description"].presence || tags["og:title"].presence || tags["description"].presence,
        image: tags["twitter:image"].presence || tags["og:image"].presence || tags["image"].presence,
      }
      if !only_image && (tags.empty? || image_data?(res.body))
        meta_data[:image] ||= url
      end

      meta_data
    end

    return if meta_data.blank?
    response_data = {
      title: meta_data[:title].presence || meta_data[:url],
      original_url: raw_url,
      url: meta_data[:url].presence || url,
      inline: meta_data[:video_url].present? || meta_data[:only_image],
      html: ApplicationController.render(partial: "layouts/link_preview", locals: meta_data)
    }
  end

  def image_data?(data)
    png_data?(data) || jpeg_data?(data) || gif_data?(data) || bitmap_data?(data)
  end

  def png_data?(data)
    data.starts_with?("\x89PNG".b) rescue false
  end

  def jpeg_data?(data)
    data.starts_with?("\xff\xd8\xff\xe0".b) rescue false
  end

  def gif_data?(data)
    data.starts_with?("GIF8".b) rescue false
  end

  def bitmap_data?(data)
    data.starts_with?("MB".b) rescue false
  end

end
