module CoreExtensions
  refine Object do
    def to_html; self.to_s; end
  end
  refine Hash do
    def to_html
      self.symbolize_keys!
      tag = "div"
      attributes_hash = {}
      inner_content = ""

      self.each do |hash_key, hash_val|
        case hash_key.try(:to_sym)
        when :tag
          tag = hash_val
        when :style
          hash_val = hash_val.to_styles if hash_val.is_a?(Hash)
          stringified_classes = [hash_val].flatten.map(&:to_s)
          attributes_hash[:style] = (attributes_hash[:style].to_s.split(";") + stringified_classes).join("; ").squish
        when :html
          inner_content += hash_val.to_html
        else # assume html attribute name such as class, etc...
          hash_val = hash_val.join(" ") if hash_val.is_a?(Array)
          attributes_hash[hash_key] = (attributes_hash[hash_key].to_s.split(" ") + hash_val.to_s.split(" ")).join(" ").squish
        end
      end

      "<#{tag}#{attributes_hash.to_html_attributes}>#{inner_content}</#{tag}>"
    end

    def to_styles
      self.map do |hash_key, hash_val|
        "#{hash_key}: #{hash_val}"
      end
    end

    def to_html_attributes
      attr_str = ""
      self.each do |hash_key, hash_val|
        attr_str += " #{hash_key}"
        attr_str += "=\"#{hash_val}\"" if hash_key.to_s.length > 0 && hash_val.to_s.length > 0
      end
      attr_str
    end
  end
  refine Array do
    def to_html
      self.map { |obj| obj.to_html }.join("")
    end
  end
end
