class ObscenityChecker
  class << self

    def profane?(text)
      Obscenity.profane?(text)
    end

    def blacklist
      @@blacklist ||= begin
        Obscenity::Base.blacklist + [
          :buttsex
        ].map(&:to_s) - whitelist.map(&:to_s)
      end
    end

    def whitelist
      [:as]
    end

    def maybe_profane?(text)
      blacklist.select { |b| b.length > 3 }.any? do |profanity|
        print " #{profanity}".colorize(:cyan)
        found_profanity = text.to_s =~ Regexp.new(leet_regexp(profanity.to_s.downcase))
        # CustomLogger.log("Found Profanity: #{profanity} : #{leet_regexp(profanity.to_s.downcase)} in #{text}") if found_profanity
        found_profanity.present?
      end
    end

    def leet_regexp(text)
      text.gsub!(/\W|_/, '') # Remove whitespace
      text.gsub!(/(0|o|q)/, '(0|o|q)')
      text.gsub!(/(i|l|1)/, '(i|l|1)')
      text.gsub!(/(p|z|2)/, '(p|z|2)')
      text.gsub!(/(b|e|3|8)/, '(b|e|3|8)')
      text.gsub!(/(a|4)/, '(a|4)')
      text.gsub!(/(s|5|\$)/, '(s|5|\$)')
      text.gsub!(/(g|6|9)/, '(g|6|9)')
      text.gsub!(/(t|7)/, '(t|7)')
      text
    end

  end
end
