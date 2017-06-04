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
  belongs_to :viewed_by, class_name: "User"

  validate :one_view_per_hour_per_user

  private

  def one_view_per_hour_per_user
    now = created_at || DateTime.current
    threshold = 1.hour
    if post.views.where("viewed_by_id = :viewed_by_id AND created_at > :threshold", viewed_by_id: viewed_by_id, threshold: now - threshold).any?
      errors.add(:base, "Already viewed")
    end
  end

end
