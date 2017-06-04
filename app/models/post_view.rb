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

  belongs_to :post
  belongs_to :viewed_by, class_name: :user

  validates :one_view_per_hour_per_user

  private

  def one_view_per_hour_per_user
    # post.views.where()
  end

end
