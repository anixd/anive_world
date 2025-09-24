class CreateMorphemes < ActiveRecord::Migration[7.2]
  def change
    create_table :morphemes do |t|
      t.references :lexeme, null: false, foreign_key: true
      t.references :morphemable, polymorphic: true, null: false
      t.integer :position, null: false

      t.timestamps
    end

    add_index :morphemes, [:lexeme_id, :position]

    add_index :morphemes, [:morphemable_type, :morphemable_id]

    add_index :morphemes, [:lexeme_id, :morphemable_id, :morphemable_type], unique: true, name: 'index_morphemes_on_lexeme_and_morphemable'
  end
end
