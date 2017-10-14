class AddSimilarTagNamesToTag < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :similar_tag_id_string, :text, index: true
  end
end
