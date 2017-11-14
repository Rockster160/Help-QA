class AddMoreIdsToSubscriptions < ActiveRecord::Migration[5.0]
  def change
    add_reference :notices, :post
    add_reference :notices, :reply
    add_reference :notices, :friend

    reversible do |migration|
      migration.up do
        Notice.find_each do |notice|
          notice.update_attributes(post_id: notice.notice_for_id) if notice.subscription?
          notice.update_attributes(friend_id: notice.notice_for_id) if notice.friend_request?
        end
      end
    end

    remove_column :notices, :notice_for_id
  end
end
