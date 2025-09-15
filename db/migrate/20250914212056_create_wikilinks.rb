class CreateWikilinks < ActiveRecord::Migration[7.2]
  def change
    create_table :wikilinks do |t|
      t.references :source, polymorphic: true, null: false
      t.string :target_slug, null: false
      t.string :target_type, null: false
      t.string :target_language_code

      t.timestamps
    end
    add_index :wikilinks, [:source_type, :source_id]
    add_index :wikilinks, [:target_type, :target_slug]
  end
end
