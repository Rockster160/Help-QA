module LinkPreviewHelper

  def generate_previews_for_urls
    [params[:urls]].flatten.compact.uniq.map do |url|
      url = url.gsub("&amp;", "&") # Hack because JS persistently escapes ampersands
      meta_data = Rails.cache.fetch(url) do
        puts "Running Cache Fetch for: #{url}".colorize(:yellow)
        res = RestClient.get(url)
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

        meta_data
      end

      response_data = {
        title: meta_data[:title].presence || meta_data[:url],
        url: meta_data[:url],
        inline: meta_data[:video_url].present? || meta_data[:only_image],
        html: ApplicationController.render(partial: "layouts/link_preview", locals: meta_data)
      }
    end

  end
end
