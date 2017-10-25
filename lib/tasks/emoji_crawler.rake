task :emoji do
  File.open("lib/emoji2.json", "w") do |f|
    f.puts("{")
    url = "http://www.unicode.org/emoji/charts/full-emoji-list.html"
    res = RestClient.get(url)
    doc = Nokogiri::HTML(res.body)
    doc.search(".code").each do |code_element|
      begin
        code = code_element.children.last.attributes["name"].value
        code = code.split("_").map { |single_code| "&#x#{single_code}" }.join("")
        raw_emoji = code_element.parent.search(".chars").first.children.first.text
        text_name = code_element.parent.search("td").last.children.first.text
        text_name = text_name.downcase.gsub(" ", "_").gsub(/[^a-z_]/, "").gsub(/^_|_$/, "").gsub("__", "_")
        f.puts("  \"#{code},#{raw_emoji}\": [\"#{text_name}\"],")
      rescue => e
        puts "#{e}".colorize(:red)
      end
    end
    f.puts("}")
  end
end
