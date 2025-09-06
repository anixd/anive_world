class CreateLexemes < ActiveRecord::Migration[7.2]
  def change
    create_table :lexemes do |t|
      t.string :spelling
      t.references :language, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :slug, null: false
      t.datetime :discarded_at, default: nil

      t.timestamps
    end

    add_index :lexemes, :discarded_at
    add_index :lexemes, [:slug, :language_id], unique: true, where: "discarded_at IS NULL"
    add_index :lexemes, [:spelling, :language_id], unique: true, where: "discarded_at IS NULL"
  end
end
