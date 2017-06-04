class CreatePost < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.text :body
      t.belongs_to :author
      t.boolean :posted_anonymously
      t.datetime :closed_at

      t.timestamps
    end
    create_table :post_edits do |t|
      t.belongs_to :post
      t.belongs_to :edited_by
      t.datetime :edited_at
      t.text :previous_body
    end
    create_table :post_views do |t|
      t.belongs_to :post
      t.belongs_to :viewed_by
      t.datetime :created_at
    end
    create_table :subscriptions do |t|
      t.belongs_to :post
      t.belongs_to :user
      t.datetime :created_at
    end
    create_table :comments do |t|
      t.text :body
      t.belongs_to :user
      t.boolean :posted_anonymously
      t.boolean :has_questionable_text

      t.timestamps
    end
    create_table :report_flags do |t|
      t.belongs_to :reported_by
      t.belongs_to :user
      t.belongs_to :post
      t.belongs_to :comment

      t.timestamps
    end
    create_table :tags do |t|
      t.string :tag_name
      t.integer :tags_count
    end
    create_table :post_tags do |t|
      t.belongs_to :tag
      t.belongs_to :post
    end
  end
end
