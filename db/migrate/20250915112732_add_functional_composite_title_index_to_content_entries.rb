class AddFunctionalCompositeTitleIndexToContentEntries < ActiveRecord::Migration[7.2]
  INDEX_NAME = "index_content_entries_on_type_and_lower_title"

  def up
    remove_index :content_entries, name: "index_content_entries_on_type_and_title", if_exists: true

    execute <<-SQL
      CREATE INDEX #{INDEX_NAME}
      ON content_entries (type, LOWER(title));
    SQL
  end

  def down
    remove_index :content_entries, name: INDEX_NAME
  end
end