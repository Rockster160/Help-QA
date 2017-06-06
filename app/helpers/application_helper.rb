module ApplicationHelper
  using CoreExtensions

  def timeago(time, options={})
    options[:class] ||= "timeago"
    if options[:strftime].present?
      simple_time = time.strftime(options[:strftime])
    elsif options[:to_formatted_s].present?
      simple_time = time.to_formatted_s(options[:to_formatted_s])
    else
      simple_time = time.to_formatted_s(:simple)
    end
    content_tag(:time, simple_time, options.merge(datetime: time.to_i, title: simple_time)) if time
  end

  def avatar(avatar_src, options={})
    avatar_container_hash = {}
    avatar_container_hash[:tag] = "a" if options[:href].present?
    avatar_container_hash[:class] = ["avatar-container"]
    avatar_container_hash[:style] = []
    avatar_container_hash[:html] = []

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
      avatar_hash[:style] << "font-size: #{options[:size].to_i - 5}px; line-height: #{options[:size]}px;"
    end

    avatar_img = avatar_src && avatar_src.length > 5 ? image_tag(avatar_src) : avatar_src
    avatar_hash[:html] << avatar_img

    avatar_wrapper_hash[:html] << avatar_hash
    avatar_container_hash[:html] << avatar_wrapper_hash

    avatar_container_hash.to_html.html_safe
  end

end
