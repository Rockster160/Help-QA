class AddToSherlock < ActiveRecord::Migration[5.0]
  def change
    reversible do |migration|
      migration.up do
        Sherlock.destroy_all
        ActiveRecord::Base.connection.reset_pk_sequence!('sherlocks')
      end
    end

    add_column :sherlocks, :acting_ip, :inet
    add_column :sherlocks, :explanation, :text
    add_column :sherlocks, :discovery_klass, :string
    add_column :sherlocks, :discovery_type, :integer
    add_column :sherlocks, :changed_attrs, :text

    rename_column :sherlocks, :changed_by_id, :acting_user_id
    rename_column :sherlocks, :new_attributes_raw, :new_attributes

    remove_column :sherlocks, :previous_attributes_raw, :text
  end
end
