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

  def first_sentence(post_title)
    str = post_title.split(/!|\.|\n|;|\?|\r/).reject(&:blank?).first
    post_title[0..str.length]
  end

  def short_title(post_title)
    cut_title = cut_string_before_index_at_char(first_sentence(post_title), 100)
    return cut_title if cut_title.length <= 100
    "#{cut_title}..."
  end

  def cut_string_before_index_at_char(str, idx, letter=" ")
    return str if str.length <= idx
    indices_of_letter = str.split("").map.with_index { |l, i| i if l == letter }.compact
    indices_before_index = indices_of_letter.select { |i| i <= idx }
    str[0..indices_before_index.last.to_i - 1]
  end

end
