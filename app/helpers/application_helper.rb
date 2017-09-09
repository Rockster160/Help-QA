module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  using CoreExtensions

  def tags_container(tags, min:, max:)
    max_tag_count = tags.count_order.first.tags_count
    min_tag_count = tags.count_order.last.tags_count

    tags.map do |tag|
      size = range_map(tag.tags_count, min_tag_count, max_tag_count, min, max)
      "<a href=\"#{tag_path(tag)}\" class=\"underline\" style=\"font-size: #{size}px;\" title=\"#{tag.tags_count} posts\">#{tag.tag_name}</a>"
    end.join(", ").html_safe
  end

  def range_map(input, input_start, input_end, output_start, output_end)
    input, input_start, input_end, output_start, output_end = [input, input_start, input_end, output_start, output_end].map(&:to_i)
    output_start + ((output_end - output_start) / (input_end - input_start).to_f) * (input - input_start)
  end

  def filter_posts_link(link_text, options={})
    new_filter_options = options.slice(:claimed_status, :reply_count, :user_status)

    current_filters = @filter_params

    selected_filter_key = new_filter_options.keys.first
    selected_filter_value = new_filter_options.values.first
    current_filter_value = current_filters[selected_filter_key]

    current_filter_is_selected = current_filters.values.any? { |param_val| new_filter_options.values.include?(param_val) }
    if current_filter_is_selected || current_filter_value.nil? && selected_filter_value.nil?
      sorted_class = "current-filter"
    end

    current_filters = current_filters.merge(new_filter_options).reject { |param_key, param_val| param_val.blank? }
    current_filters[:tags] = current_filters[:tags].join(",") if current_filters[:tags].present?

    link_to link_text, "/#{(['history'] + current_filters.values).join("/")}#{filter_query_string}", class: "#{sorted_class} #{options[:class]}"
  end

  def build_history_path(workable_params=params)
    if workable_params.is_a?(ActionController::Parameters)
      workable_params[:tags] = workable_params.permit(:tags, :new_tag).values.join(",")
      workable_params.delete(:tags) unless workable_params[:tags].present?
      workable_params.delete(:new_tag)
      attached_params = workable_params.permit(:claimed_status, :reply_count, :user_status, :tags, :page).values.join("/")
    else
      workable_params[:tags] = workable_params.slice(:tags, :new_tag).values.join(",")
      workable_params.delete(:tags) unless workable_params[:tags].present?
      workable_params.delete(:new_tag)
      attached_params = workable_params.slice(:claimed_status, :reply_count, :user_status, :tags, :page).values.join("/")
    end
    "#{history_path}/#{attached_params}#{filter_query_string}"
  end

  def filter_query_string
    additional_queries = []
    additional_queries << "search=#{params[:search]}" if params[:search].present?
    additional_queries << "by_user=#{params[:by_user]}" if params[:by_user].present?
    additional_queries << "new_tag=#{params[:new_tag]}" if params[:new_tag].present?
    additional_queries.any? ? "?#{additional_queries.join('&')}" : ""
  end

  def pagination(association, options={})
    current_filters = @filter_options.reject { |param_key, param_val| param_val.blank? }
    tags = current_filters.delete(:tags)
    current_filter_str = (['history'] + current_filters.keys + [tags&.join(",")]).compact.join("/")

    paginate(association, options).gsub(/history.*?\d?"/) do |found_match|
      page = found_match.scan(/\/\d+/).first.presence || "/1"
      "#{current_filter_str}#{page}#{filter_query_string}\""
    end.html_safe
  end

  def timeago(time, options={})
    return unless time
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
    style = "background-image: url(#{image_url('icon_sheet.png')})"
    img = image_tag("blank.png", alt: alt, title: alt, style: style, class: "icon #{icon}")
    if options[:href].present?
      "<a href=\"#{options[:href]}\" class=\"hover-icon\" data-method=\"#{options[:method] || "GET"}\">#{img}#{options[:text]}</a>".html_safe
    else
      "<div class=\"hover-icon\">#{img}#{options[:text]}</div>".html_safe
    end
  end

  def avatar(avatar_src, options={})
    avatar_container_hash = {}
    avatar_container_hash[:tag] = "a" if options[:href].present?
    avatar_container_hash[:href] = options[:href] if options[:href].present?
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
    avatar_hash[:title] = options[:title]

    avatar_wrapper_hash[:html] << avatar_hash
    avatar_container_hash[:html] << avatar_wrapper_hash

    avatar_container_hash.to_html.html_safe
  end

end
