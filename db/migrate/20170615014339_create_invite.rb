class CreateInvite < ActiveRecord::Migration[5.0]
  def change
    create_table :invites do |t|
      t.belongs_to :from_user
      t.belongs_to :invited_user
      t.belongs_to :post

      t.datetime :created_at
    end
  end
end
