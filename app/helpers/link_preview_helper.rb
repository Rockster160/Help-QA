module LinkPreviewHelper

  def generate_previews_for_urls(clear: false)
    [params[:urls]].flatten.compact.uniq.map do |raw_url|
      meta_data = retrieve_meta_data_for_url(raw_url, clear: clear, generate_if_nil: true)
      meta_data[:html] = render_link_from_meta_data(meta_data)
puts "#{raw_url}: #{meta_data}".colorize(:light_red)
      meta_data
    end.compact
  end

  def retrieve_meta_data_for_url(raw_url, clear: false, generate_if_nil: false)
    url = raw_url.gsub(/^\/\//, "")
    Rails.cache.delete(url) if clear
    meta_data = Rails.cache.read(url)
    return if meta_data.blank? && !generate_if_nil
    return meta_data unless meta_data.nil?
    puts "Collecting meta data for: ~#{url}~".colorize(:green)
    meta_data = get_meta_data_for_url(url)
    raise("Broken stuff") if meta_data.blank?
    puts "#{meta_data}".colorize(:light_black)
    meta_data
  end

  def render_link_from_meta_data(meta_data)
    ApplicationController.render(partial: "layouts/link_preview", locals: meta_data)
  end

  def get_meta_data_for_url(url)
    Rails.cache.fetch(url, expires_in: 30.days) do
      puts "Running Cache Fetch for: ~#{url}~".colorize(:yellow)
      res = RestClient.get(url, timeout: 3) rescue nil
      next {url: url, invalid_url: true} if res.nil?

      doc = Nokogiri::HTML(res.body)
      only_image = MIME::Types.type_for(url).first.try(:content_type)&.starts_with?("image")

      tags = {}
      doc.search("meta").each do |meta_tag|
        meta_type = meta_tag["property"].presence || meta_tag["name"].presence
        next unless meta_type.present?

        tags[meta_type] = meta_tag["content"]
      end
      favicon_element = doc.xpath('//link[@rel="shortcut icon"]').first || doc.xpath('//link[@rel="icon"]').first || doc.xpath('//link[@rel="favicon"]').first

      video_url = tags["twitter:player"]
      should_iframe = if video_url.present?
        video_url.include?("player.vimeo") || video_url.include?("youtube.com/embed")
      elsif url.present?
        if url.include?("player.vimeo") || url.include?("youtube.com/embed")
          video_url = url
          true
        elsif url =~ /vimeo.com\/\d+$/
          video_url = "https://player.vimeo.com/video/#{url[/\d+$/]}"
          true
        end
      end

      url_meta_data = {
        url: url,
        request_url: res.request.url,
        favicon: favicon_element.present? ? favicon_element["href"] : nil,
        title: doc.title,
        description: tags["twitter:description"].presence || tags["twitter:title"].presence || tags["og:description"].presence || tags["og:title"].presence || tags["description"].presence,
        inline: video_url.present? || only_image,
        should_iframe: should_iframe,
        video_url: video_url,
        image_url: tags["twitter:image"].presence || tags["og:image"].presence || tags["image"].presence,
        only_image: only_image,
        invalid_url: false
      }
      if !only_image && (tags.empty? || image_data?(res.body))
        url_meta_data[:image] ||= url
        url_meta_data[:only_image] = true
        url_meta_data[:inline] = true
      end

      url_meta_data
    end
  end

  def image_data?(data)
    png_data?(data) || jpeg_data?(data) || gif_data?(data) || bitmap_data?(data)
  end

  def png_data?(data)
    data.starts_with?("\x89PNG".b) || data.starts_with?("\x89png".b) rescue false
  end

  def jpeg_data?(data)
    data.starts_with?("\xff\xd8\xff\xe0".b) || data.starts_with?("\xFF\xD8\xFF\xE0".b) rescue false
  end

  def gif_data?(data)
    data.starts_with?("GIF8".b) || data.starts_with?("gif8".b) rescue false
  end

  def bitmap_data?(data)
    data.starts_with?("MB".b) || data.starts_with?("mb".b) rescue false
  end

end
