class ColorGenerationError < StandardError; end
module ColorGenerator
  class << self

    def fade(from_hex, to_hex, steps=10, fade_back=false)
      steps ||= 10
      steps = steps.to_i
      raise ColorGenerationError.new("Cannot fade more than 256 steps!") if steps > 256
      start_hex = conform_hex(from_hex)
      end_hex = conform_hex(to_hex)
      fade_back = (fade_back || fade_back == 'true')
      return [] if steps <= 0
      return [start_hex] if steps == 1
      return [start_hex, end_hex] if steps == 2
      from_red, from_green, from_blue = hex_to_rgb(start_hex)
      raise ColorGenerationError.new("Start color must be a Hex value!") unless [from_red, from_green, from_blue].compact.length == 3
      to_red, to_green, to_blue = hex_to_rgb(end_hex)
      raise ColorGenerationError.new("End color must be a Hex value!") unless [to_red, to_green, to_blue].compact.length == 3
      temp_steps = steps - 1
      step_red, step_green, step_blue = [(to_red - from_red) / temp_steps.to_f, (to_green - from_green) / temp_steps.to_f, (to_blue - from_blue) / temp_steps.to_f]
      colors = []
      (steps - 1).times do |t|
        nr = from_red + (step_red * t)
        ng = from_green + (step_green * t)
        nb = from_blue + (step_blue * t)
        colors << rgb_to_hex([nr, ng, nb])
      end
      colors << end_hex
      if fade_back
        back_colors = colors.dup
        back_colors.pop # Remove the first color
        back_colors.reverse!
        back_colors.pop # Remove the last color
        colors += back_colors
      end
      return colors.compact
    end

    def lighten_pure_hex(hex, percent)
      raise ColorGenerationError.new("Cannot lighten non-hex!") unless hex.length.in?(1..2)
      valid_hex = hex.length == 1 ? "#{hex}#{hex}" : hex
      rgb = valid_hex.to_i(16)
      fade_from_white = (255 - rgb) * (percent/100.to_f)
      lightened_rgb = [0, rgb + fade_from_white, 255].sort[1]
      lightened_hex = lightened_rgb.round.to_s(16)
      fixed_hex = lightened_hex.length == 1 ? "0#{lightened_hex}" : lightened_hex
    end

    def lighten(full_hex, percent)
      hex_without_hash = full_hex.gsub("#", '')
      raise ColorGenerationError.new("Cannot lighten non-hex!") unless hex_without_hash.length.in?([3, 6])
      rhex, ghex, bhex = hex_without_hash.length == 6 ? hex_without_hash.scan(/../) : hex_without_hash.scan(/./)
      "##{lighten_pure_hex(rhex, percent)}#{lighten_pure_hex(ghex, percent)}#{lighten_pure_hex(bhex, percent)}"
    end

    def darken(full_hex, percent)
      lighten(full_hex, -percent)
    end

    def hex_to_rgb(hex)
      hex_without_hash = hex.gsub("#", '')
      if hex_without_hash.length == 6
        return hex_without_hash.scan(/.{2}/).map { |rgb| rgb.to_i(16) }
      elsif hex_without_hash.length == 3
        return hex_without_hash.split('').map { |rgb| "#{rgb}#{rgb}".to_i(16) }
      else
        return nil
      end
    end

    def rgb_to_hex(rgb)
      r, g, b = rgb.map { |val| new_val = [val.round, 0, 255].sort[1].to_s(16); new_val.length == 1 ? "0#{new_val}" : new_val }
      "##{r}#{g}#{b}".upcase
    end

    def conform_hex(hex_try)
      new_hex = hex_try.to_s.squish.upcase
      new_hex = new_hex.gsub("#", '')
      raise ColorGenerationError.new("Hex values can only be characters A-F and numbers 0-9") if new_hex =~ /[^a-f0-9]/i
      raise ColorGenerationError.new("Colors must be valid 3 or 6 character Hex value.") unless new_hex.length == 3 || new_hex.length == 6
      new_hex = new_hex.split("").map { |single_hex| "#{single_hex}#{single_hex}" }.join("") if new_hex.length == 3
      "##{new_hex}"
    end

    def contrast_text_color_on_background(background_hex)
      black, white = "#000", "#FFF"
      return white unless background_hex.present?
      color_hex = background_hex.gsub("#", "")
      return white unless color_hex.length == 6 || color_hex.length == 3
      r_255, g_255, b_255 = color_hex.chars.in_groups(3).map { |hex_val| (hex_val.many? ? hex_val : hex_val*2).join.to_i(16) }
      r_lum, g_lum, b_lum = r_255 * 299, g_255 * 587, b_255 * 114
      luminescence = ((r_lum + g_lum + b_lum) / 1000)
      return luminescence > 150 ? black : white
    end

  end
end
