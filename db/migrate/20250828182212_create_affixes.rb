class CreateAffixes < ActiveRecord::Migration[7.2]
  def change
    create_table :affixes do |t|
      t.string :text
      t.string :affix_type
      t.references :language, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.text :meaning
      t.datetime :discarded_at, default: nil

      t.timestamps
    end

    add_index :affixes, :discarded_at
    add_index :affixes, [:text, :language_id, :affix_type], unique: true
  end
end
