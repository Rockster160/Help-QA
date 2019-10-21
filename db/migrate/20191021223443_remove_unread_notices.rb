class RemoveUnreadNotices < ActiveRecord::Migration[5.0]
  def change
    Notice.joins(:post).where.not(posts: { closed_at: nil }).where(notices: { read_at: nil }).each(&:read!)
    Notice.joins(:post).where.not(posts: { removed_at: nil }).where(notices: { read_at: nil }).each(&:read!)
  end
end
