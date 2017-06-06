require 'rails_helper'

describe ::CoreExtensions do
  using CoreExtensions

  context "#to_hash" do
    let(:expected_html) { '<div class="wrapper" style="width: 50px;"><div class="container">Some inner content</div></div><div class="wrapper" style="background: blue; height: 150px"><div class="card wide super"></div></div><span class="spanner"><span style="color: red">Just some red text</span></span>' }
    let(:html_hash) {
      [
        {
          tag: "div",
          class: "wrapper",
          style: "width: 50px;",
          html: [
            {
              class: "container",
              html: "Some inner content"
            }
          ]
        },
        {
          class: "wrapper",
          style: ["background: blue", "height: 150px"],
          html: {
            class: ["card", "wide", "super"]
          }
        },
        {
          tag: "span",
          class: "spanner",
          html: [
            {
              tag: "span",
              style: { color: "red" },
              html: "Just some red text"
            }
          ]
        }
      ]
    }

    it "should convert the hash to HTML" do
      expect(html_hash.to_html).to eq(expected_html)
    end
  end
end
