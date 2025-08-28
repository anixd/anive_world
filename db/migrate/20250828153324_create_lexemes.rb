class CreateLexemes < ActiveRecord::Migration[7.2]
  def change
    create_table :lexemes do |t|
      t.string :spelling
      t.references :language, null: false, foreign_key: true

      t.timestamps
    end
    add_index :lexemes, [:spelling, :language_id], unique: true

  end
end
