class CreateWords < ActiveRecord::Migration[7.2]
  def change
    create_table :words do |t|
      t.references :lexeme, null: false, foreign_key: true
      t.string :type
      t.text :definition
      t.string :transcription
      t.text :comment
      t.bigint :origin_type, default: 0
      t.references :origin_word, foreign_key: { to_table: :words }
      t.references :part_of_speech, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.datetime :discarded_at, default: nil

      t.timestamps
    end
    add_index :words, :type
    add_index :words, :discarded_at
  end
end
