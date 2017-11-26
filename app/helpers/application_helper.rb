module ApplicationHelper
  include MarkdownHelper
  include MetaHelper
  include ActionView::Helpers::NumberHelper
  using CoreExtensions

  def default_anonymous?
    current_user.try(:settings).try(:default_anonymous?)
  end

  def current_mod?
    current_user.try(:mod?)
  end

  def errors(resource, error_messages=nil, title: nil)
    if resource.is_a?(String)
      resource_class = resource
      resource = nil
    end

    render partial: "layouts/errors_container", locals: { resource: resource, resource_class: resource_class, error_title: title, error_messages: error_messages }
  end

  def hash_of_url_parts(url)
    return {host: "localhost:4357"} if url == "http://localhost:4357"
    split_regex = /^((http[s]?|ftp):\/?\/?)([^:\/\s]+)((\/\w+)*\/)([\w\-\.]+[^#?\s]+)(.*)?(#[\w\-]+)?$/
    hash = {}
    url.scan(split_regex) do
      hash = {
        protocol: $1,
        host: $3,
        path: $4,
        file: $7,
        query: $7,
        hash: $8
      }
    end
    hash
  end

  def timeago(time, options={})
    return unless time
    options[:class] ||= "timeago"
    if options[:strftime].present?
      simple_time = time.strftime(options[:strftime])
    elsif options[:to_formatted_s].present?
      simple_time = time.to_formatted_s(options[:to_formatted_s])
    else
      simple_time = time.to_formatted_s(:simple_with_time)
    end
    content_tag(:time, simple_time, options.merge(datetime: time.to_i, title: simple_time)) if time
  end

  def pluralize_with_delimiter(count, word)
    "#{number_with_delimiter(count)} #{count == 1 ? word : word.pluralize}"
  end

  def time_length
    @time_length ||= begin
      length = {}
      length[:second] = 1000
      length[:minute] = 60 * length[:second]
      length[:hour] = 60 * length[:minute]
      length[:day] = 24 * length[:hour]
      length[:week] = 7 * length[:day]
      length[:month] = 30 * length[:day]
      length[:year] = 12 * length[:month]
      length
    end
  end

  def time_difference_in_words(start_time, end_time, options={})
    word_count = options[:word_count] || 2
    distanceMs = (start_time.to_f - end_time.to_f).abs * 1000
    words = []

    time_length.reverse_each do |str, val|
      if distanceMs > val
        time_count = (distanceMs / val).floor
        pluralize = time_count > 1 ? "s" : ""
        words << "#{time_count} #{str}#{pluralize}"
        distanceMs = distanceMs % val
      end
    end

    words.first(word_count).join(", ")
  end

  def hover_icon(icon, alt, options={})
    style = "background-image: url(#{ActionController::Base.helpers.asset_path('icon_sheet.png', digest: false)})"
    img = ActionController::Base.helpers.image_tag("blank.png", alt: alt, title: alt, style: style, class: "icon #{icon.to_s.gsub('_', '-')}")
    data = options[:data]&.map { |k,v| "data-#{k}=\"#{v}\"" }&.join(" ") || ""

    if options[:href].present?
      method = options[:method].present? ? "data-method=\"#{options[:method]}\"" : ""
      "<a rel=\"nofollow\" href=\"#{options[:href]}\" title=\"#{alt}\" #{data} class=\"hover-icon #{options[:class]}\" #{method}>#{img}#{options[:text]}</a>".html_safe
    else
      options[:tag] ||= "div"
      "<#{options[:tag]} #{data} class=\"hover-icon #{options[:class]}\">#{img}#{options[:text]}</#{options[:tag]}>".html_safe
    end
  end
  module_function :hover_icon

  def avatar(avatar_src, options={})
    avatar_container_hash = {}
    avatar_container_hash[:tag] = "a" if options[:href].present?
    avatar_container_hash[:href] = options[:href] if options[:href].present?
    avatar_container_hash[:class] = ["avatar-container #{options[:border]}"]
    avatar_container_hash[:style] = []
    avatar_container_hash[:html] = []
    avatar_container_hash[:title] = options[:title]

    avatar_wrapper_hash = {}
    avatar_wrapper_hash[:class] = ["avatar-img-wrapper"]
    avatar_wrapper_hash[:style] = []
    avatar_wrapper_hash[:html] = []

    avatar_hash = {}
    avatar_hash[:class] = ["avatar"]
    avatar_hash[:style] = []
    avatar_hash[:html] = []

    if options[:tooltip].present?
      avatar_container_hash[:class] << "show-tooltip"
      avatar_container_hash[:html] << {
        class: "tooltip hidden",
        html: [
          { class: "name", html: options[:tooltip][:name] },
          { class: "timestamp", html: options[:tooltip][:timestamp] }
        ]
      }
    end

    if options[:status].present?
      avatar_container_hash[:html] << { class: "status-indicator #{options[:status]}" }
    end

    if options[:size].present?
      avatar_container_hash[:style] = "width: #{options[:size]}px; height: #{options[:size]}px;"
      avatar_hash[:style] << "font-size: #{options[:size].to_i - 5}px; line-height: #{options[:size] - 2}px;"
    end

    avatar_img = avatar_src && avatar_src.length > 5 ? image_tag(avatar_src) : avatar_src
    avatar_hash[:html] << avatar_img

    avatar_wrapper_hash[:html] << avatar_hash
    avatar_container_hash[:html] << avatar_wrapper_hash

    avatar_container_hash.to_html.html_safe
  end

end
