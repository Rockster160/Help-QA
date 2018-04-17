# == Schema Information
#
# Table name: post_tags
#
#  id      :integer          not null, primary key
#  tag_id  :integer
#  post_id :integer
#

class PostTag < ApplicationRecord
  belongs_to :tag, counter_cache: :tags_count
  belongs_to :post

  after_create { tag.delay(:set_similar_tags) }
end
