class CreateWords < ActiveRecord::Migration[7.2]
  def change
    create_table :words do |t|
      t.references :lexeme, null: false, foreign_key: true
      t.string :type
      t.text :definition
      t.string :transcription
      t.string :part_of_speech
      t.text :comment
      t.bigint :origin_type, default: 0
      t.references :origin_word, foreign_key: { to_table: :words }

      t.timestamps
    end
    add_index :words, :type
  end
end
