class CreateSynonymRelations < ActiveRecord::Migration[7.2]
  def change
    create_table :synonym_relations do |t|
      t.references :word, null: false, foreign_key: true
      t.references :synonym, null: false, foreign_key: { to_table: :words }

      t.timestamps
    end

    add_index :synonym_relations, [:word_id, :synonym_id], unique: true
  end
end
