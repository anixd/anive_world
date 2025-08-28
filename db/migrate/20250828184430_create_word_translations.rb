class CreateWordTranslations < ActiveRecord::Migration[7.2]
  def change
    create_table :word_translations do |t|
      t.references :word, null: false, foreign_key: true
      t.references :translation, null: false, foreign_key: true

      t.timestamps
    end

    add_index :word_translations, [:word_id, :translation_id], unique: true
  end
end
