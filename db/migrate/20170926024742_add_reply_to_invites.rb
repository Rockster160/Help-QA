class AddReplyToInvites < ActiveRecord::Migration[5.0]
  def change
    add_reference :invites, :reply
    add_column :invites, :read_at, :datetime
    add_column :shouts, :read_at, :datetime
  end
end
