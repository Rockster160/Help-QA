require 'rails_helper'

describe ::CoreExtensions do
  using CoreExtensions

  context "#deep_set" do
    context "with an empty hash" do
      let(:hash) { {} }

      it "should allow a nested value to be set using dig" do
        hash.deep_set([:a, :b, :c, :d], "sup")
        expect(hash.dig(:a, :b, :c, :d)).to eq("sup")
      end
    end

    context "with a populated hash" do
      let(:hash) { {a: {c: "nope"}} }

      it "should allow a nested value to be set using dig" do
        hash.deep_set([:a, :b, :c, :d], "sup")
        expect(hash.dig(:a, :b, :c, :d)).to eq("sup")
        expect(hash.dig(:a, :c)).to eq("nope")
      end
    end
  end

  # context "#clean" do
  #   let(:dirty_hash) { { a: { b: ["a"] }, a2: ["a"], c: { d: [] } } }
  #
  #   it "should clean recursively" do
  #     dirty_hash.clean!
  #     expect(dirty_hash.keys).to match_array([:a, :a2])
  #     expect(dirty_hash[:a].keys).to match_array([:b])
  #     expect(dirty_hash[:c]).to be(nil)
  #   end
  # end
  #
  # context "#all_paths" do
  #   let(:hash) { { a: { b: ["a"] }, c: { d: [{d1: "a"}, {d2: "b"}] } } }
  #
  #   it "should return all paths recursively" do
  #     expect(hash.all_paths).to eq([[:a, :b, "a"], [:c, :d, :d1, "a"], [:c, :d, :d2, "b"]])
  #   end
  # end

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
