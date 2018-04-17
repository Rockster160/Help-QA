# == Schema Information
#
# Table name: tags
#
#  id                    :integer          not null, primary key
#  tag_name              :string
#  tags_count            :integer
#  similar_tag_id_string :text
#

require 'rails_helper'

RSpec.describe Tag, type: :model do

  context "similar tags" do
    let(:user) { ::FactoryGirl.create(:user) }
    let!(:post1) { ::FactoryGirl.create(:post, body: "this this this", author: user, skip_debounce: true) }
    let!(:post2) { ::FactoryGirl.create(:post, body: "this this this", author: user, skip_debounce: true) }
    let!(:post3) { ::FactoryGirl.create(:post, body: "this this this", author: user, skip_debounce: true) }
    let!(:post4) { ::FactoryGirl.create(:post, body: "this this this", author: user, skip_debounce: true) }

    let!(:similar_tag1) { ::FactoryGirl.create(:tag, tag_name: "love") }
    let!(:similar_tag2) { ::FactoryGirl.create(:tag, tag_name: "girl") }
    let!(:unsimilar_tag1) { ::FactoryGirl.create(:tag, tag_name: "rando") }
    let!(:unsimilar_tag2) { ::FactoryGirl.create(:tag, tag_name: "nothing") }

    let!(:post_tag1) { ::FactoryGirl.create(:post_tag, tag: similar_tag1, post: post1) }
    let!(:post_tag2) { ::FactoryGirl.create(:post_tag, tag: similar_tag1, post: post2) }
    let!(:post_tag3) { ::FactoryGirl.create(:post_tag, tag: similar_tag1, post: post3) }
    let!(:post_tag4) { ::FactoryGirl.create(:post_tag, tag: similar_tag2, post: post1) }
    let!(:post_tag5) { ::FactoryGirl.create(:post_tag, tag: similar_tag2, post: post2) }
    let!(:post_tag6) { ::FactoryGirl.create(:post_tag, tag: similar_tag2, post: post3) }
    let!(:post_tag7) { ::FactoryGirl.create(:post_tag, tag: unsimilar_tag1, post: post1) }
    let!(:post_tag8) { ::FactoryGirl.create(:post_tag, tag: unsimilar_tag1, post: post2) }
    let!(:post_tag9) { ::FactoryGirl.create(:post_tag, tag: unsimilar_tag2, post: post4) }

    it "should only return tags that have at least 3 posts in common" do
      expect(similar_tag1.reload.similar_tags).to match_array([similar_tag2])
      expect(unsimilar_tag1.reload.similar_tags).to match_array([])
    end
  end
end
