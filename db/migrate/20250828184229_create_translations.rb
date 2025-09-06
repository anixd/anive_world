class CreateTranslations < ActiveRecord::Migration[7.2]
  def change
    create_table :translations do |t|
      t.string :text, null: false
      t.string :language, null: false
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.datetime :discarded_at, default: nil

      t.timestamps
    end

    add_index :translations, :discarded_at
    add_index :translations, [:text, :language], unique: true
  end
end
