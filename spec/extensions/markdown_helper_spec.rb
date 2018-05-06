require 'rails_helper'

describe ::MarkdownHelper do
  include MarkdownHelper

  context "actual markdown" do
    it "should properly replace markdown at the beginning and end of a string" do
      expect(markdown { "_italic_" }).to eq("<p><i>italic</i></p>")
    end
    it "should properly replace markdown anywhere inside of a string" do
      expect(markdown { "This is *bold* and ~this is crossed~ out" }).to eq("<p>This is <strong>bold</strong> and <strike>this is crossed</strike> out</p>")
    end

    it "should properly replace multiple instances of markdown" do
      expect(markdown { "_*Bold italic*_" }).to eq("<p><i><strong>Bold italic</strong></i></p>")
    end
    it "should nest markdown" do
      expect(markdown { "_Some italics *with some bold* inside_" }).to eq("<p><i>Some italics <strong>with some bold</strong> inside</i></p>")
    end

    it "does not count if markdown is touching other characters" do
      expect(markdown { "_this_is_just_snake case_" }).to eq("<p><i>this_is_just_snake case</i></p>")
    end
    it "does not count multi-stars as bold" do
      expect(markdown { "*This is some *** word*" }).to eq("<p><strong>This is some &#42;&#42;&#42; word</strong></p>")
    end

    it "allows single character usage" do
      expect(markdown { "_I_" }).to eq("<p><i>I</i></p>")
    end
    it "does not allow no chars" do
      expect(markdown { "__" }).to eq("<p>__</p>")
    end
    it "allows a few special characters after the string" do
      expect(markdown { "I use *markdown*, with _special characters!_" }).to eq("<p>I use <strong>markdown</strong>, with <i>special characters!</i></p>")
    end
  end

  context "url_regex" do
    context "link_parts" do
      it "properly splits the url into the expected chunks" do
        url = "http://www.sub.domain.com:80/my/path/to/file.jpg/?user[group]=%20stuff&something#jump-here"
        link_parts = url.scan(url_regex).first
        protocol, domain, tld, port, path, params, anchor = link_parts

        expect(protocol).to eq("http://")
        expect(domain).to   eq("www.sub.domain.")
        expect(tld).to      eq("com")
        expect(port).to     eq(":80")
        expect(path).to     eq("/my/path/to/file.jpg/")
        expect(params).to   eq("?user[group]=%20stuff&something")
        expect(anchor).to   eq("#jump-here")
      end
    end

    context "valid urls" do
      urls = [
        "https://www.pinterest.com/doc1273/playboy-playmates-of-the-month-every-one-of-them-e/",
        "https://en.wikipedia.org/wiki/Chicken_Ranch_(Nevada)",
        "http://www.example.com:1030/software/index.html",
        "http://www.example.com/software/index.html",
        "https://i.pinimg.com/736x/90/af/01/90af01a46427a8d83ff0949280e9a737--walking-cartoon.jpg",
        "https://web.archive.org/web/20140119020127/http://www.help.com/",
        # "localhost:9949",
        # Ideally, this should match, but it doesn't because it's missing a TLD, and the workaround isn't really worth it.
        # "http://ar.wikipedia.org/wiki/%D8%A7%D9%84%D8%A5%D9%85%D8%A7%D8%B1%D8%A7%D8%AA_%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9_%D8%A7%D9%84%D9%85%D8%AA%D8%AD%D8%AF%D8%A9",
        # This one doesn't match because of the escaped codes in the path rather than the params. Not sure if that's allowed.
        "help-qa.com",
        "https://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js",
        "https://platform.twitter.com/widgets/widget_iframe.83d5793f6ebbe2046330abda6016ae93.html?origin=https%3A%2F%2Fperishablepress.com",
        "https://accounts.google.com/o/oauth2/postmessageRelay?parent=https%3A%2F%2Fperishablepress.com&jsh=m%3B%2F_%2Fscs%2Fapps-static%2F_%2Fjs%2Fk%3Doz.gapi.en.R44Wtk-gxDE.O%2Fm%3D__features__%2Fam%3DAQE%2Frt%3Dj%2Fd%3D1%2Frs%3DAGLTcCPte9SScuiQap0QQNwXhM_udO59RQ#rpctoken=654941641&forcesecure=1",
        "https://secure.gravatar.com/avatar/ae21e3af46811c9ad1c8494e867d45d7?s=70&d=https%3A%2F%2Fperishablepress.com%2Fwp%2Fwp-content%2Fthemes%2Fwire%2Fimg%2Favatar.png",
        "text.com/sup/foor/?user[nest][sup]=name%20last&user[another]=thing",
        "http://www.sup.domain.com:80/my/path/to/file.jpg/?user[group]=%20stuff&something#jump-here"
      ]

      urls.each do |url|
        it "should return match data" do
          expect(url_regex.match(url).to_s).to eq(url)
        end
      end
    end

    context "invalid urls" do
      urls = [
        "not..this..either",
        "or..this",
        "nor...this",
        "foo://example.com:8042/over/there?name=ferret#nose-thiing",
        # Does not match because foo: is not accepted
        "(((.asd"
      ]

      urls.each do |url|
        it "should return match data" do
          expect(url_regex.match(url).to_s).to_not eq(url)
        end
      end
    end
  end
end
