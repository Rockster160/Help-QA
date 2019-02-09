# == Schema Information
#
# Table name: posts
#
#  id                 :integer          not null, primary key
#  body               :text
#  author_id          :integer
#  posted_anonymously :boolean
#  closed_at          :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  reply_count        :integer
#  marked_as_adult    :boolean
#  in_moderation      :boolean          default("false")
#  removed_at         :datetime
#

require 'rails_helper'

RSpec.describe Post, type: :model do
  context "spam" do
    let(:spam_text) { '<a href="">Click me!</a>' }

    context "class level" do
      it "should be able to check spam" do
        expect(Post.sounds_like_spam?(spam_text)).to     be(true)
        expect(Post.sounds_fake?(spam_text)).to          be(true)
        expect(Post.blacklisted_text?(spam_text)).to     be(false)
        expect(Post.sounds_like_cash_cow?(spam_text)).to be(false)
        expect(Post.sounds_like_ad?(spam_text)).to       be(false)
      end
    end

    context "instance" do
      let(:post) { FactoryGirl.build(:post, body: spam_text) }

      it "should be marked as spam" do
        expect(post.sounds_like_spam?).to     be(true)
        expect(post.sounds_fake?).to          be(true)
        expect(post.blacklisted_text?).to     be(false)
        expect(post.sounds_like_cash_cow?).to be(false)
        expect(post.sounds_like_ad?).to       be(false)
      end
    end
  end
end
