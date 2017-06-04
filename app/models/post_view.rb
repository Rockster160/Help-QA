# == Schema Information
#
# Table name: post_views
#
#  id           :integer          not null, primary key
#  post_id      :integer
#  viewed_by_id :integer
#  created_at   :datetime
#

class PostView < ApplicationRecord
end
