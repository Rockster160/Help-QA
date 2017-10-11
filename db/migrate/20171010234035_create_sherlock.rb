class CreateSherlock < ActiveRecord::Migration[5.0]
  def change
    create_table :sherlocks do |t|
      t.belongs_to :changed_by
      t.string :obj_klass
      t.integer :obj_id
      t.text :previous_attributes_raw
      t.text :new_attributes_raw

      t.timestamps
    end

    drop_table :post_edits
  end
end
