module ApplicationHelper

  def timeago(time, options = {})
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

end
