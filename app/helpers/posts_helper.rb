module PostsHelper
  include ActionView::Helpers::NumberHelper
  using CoreExtensions

  def tags_container(tags, min:, max:, min_tag_count: nil, max_tag_count: nil)
    return if tags.none?
    max_tag_count ||= tags.count_order.first.tags_count
    min_tag_count ||= tags.count_order.last.tags_count

    tags.map do |tag|
      size = range_map(tag.tags_count, min_tag_count, max_tag_count, min, max)
      "<a href=\"#{tag_path(tag)}\" class=\"underline\" style=\"font-size: #{size}px;\" title=\"#{tag.tags_count} posts\">#{tag.tag_name}</a>"
    end.join(", ").html_safe
  end

  def range_map(input, input_start, input_end, output_start, output_end)
    input, input_start, input_end, output_start, output_end = [input, input_start, input_end, output_start, output_end].map(&:to_i)
    output_start + ((output_end - output_start) / (input_end - input_start).to_f) * (input - input_start)
  end

  def filter_feedback_link(link_text, resolution_status:)
    filtered_params = params.permit(:search, :by_user)
    if params[:resolution_status].to_s == resolution_status.to_s
      sorted_class = "current-filter"
    end

    link_to link_text, all_feedback_path(filtered_params.merge(resolution_status: resolution_status)), class: "#{sorted_class}"
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

  def current_tags(workable_params=params)
    workable_params.permit(:tags, :new_tag)
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

  def feedback_pagination(association, options={})
    new_params = params.permit(:search, :by_user, :resolution_status)

    paginate(association, options).gsub(/href=".*?"/) do |found_href|
      page = found_href.scan(/page=\d+/).first&.gsub("page=", "") || "1"
      found_href.split("?").first + "?#{URI.encode_www_form(new_params.merge(page: page))}\""
    end.html_safe
  end

  def pagination(association, options={})
    current_filters = @filter_options.reject { |param_key, param_val| param_val.blank? }
    tags = current_filters.delete(:tags)
    current_filter_str = (['history'] + current_filters.keys + [tags.try(:compact)&.join(",")]).compact.join("/")

    paginate(association, options).gsub(/history.*?\d?"/) do |found_match|
      page = found_match.scan(/\/\d+/).first.presence || "/1"
      "#{current_filter_str}#{page}#{filter_query_string}\""
    end.html_safe
  end

  def set_feedback_filters
    filter_values = params.permit(:resolution_status)

    @filter_options = {
      "resolved" => false,
      "unresolved" => false
    }

    filter_values.each do |filter_val|

    end

    @filter_params = {}
  end

  def set_filter_params
    filter_values = params.permit(:claimed_status, :reply_count, :user_status, :tags, :page, :new_tag).values

    @filter_options = {
      "claimed"      => false,
      "unclaimed"    => false,
      "no-replies"   => false,
      "some-replies" => false,
      "few-replies"  => false,
      "many-replies" => false,
      "verified"     => false,
      "unverified"   => false
    }

    filter_values.each do |filter_val|
      if @filter_options.keys.include?(filter_val)
        @filter_options[filter_val] = true
      elsif filter_val =~ /[^0-9]+/
        @filter_options[:tags] ||= []
        @filter_options[:tags] += filter_val.split(",").map(&:squish)
      end
    end

    @filter_params = {}
    @filter_params[:claimed_status] = "claimed" if @filter_options["claimed"]
    @filter_params[:claimed_status] = "unclaimed" if @filter_options["unclaimed"]
    @filter_params[:reply_count] = "no-replies" if @filter_options["no-replies"]
    @filter_params[:reply_count] = "some-replies" if @filter_options["some-replies"]
    @filter_params[:reply_count] = "few-replies" if @filter_options["few-replies"]
    @filter_params[:reply_count] = "many-replies" if @filter_options["many-replies"]
    @filter_params[:user_status] = "verified" if @filter_options["verified"]
    @filter_params[:user_status] = "unverified" if @filter_options["unverified"]
    @filter_params[:tags] = @filter_options[:tags].uniq if @filter_options[:tags].present?
  end

end
