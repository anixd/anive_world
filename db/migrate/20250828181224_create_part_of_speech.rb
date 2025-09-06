class CreatePartOfSpeech < ActiveRecord::Migration[7.2]
  def change
    create_table :parts_of_speech do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :explanation
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.datetime :discarded_at, default: nil

      t.timestamps
    end
    add_index :parts_of_speech, :discarded_at
    add_index :parts_of_speech, :code, unique: true
  end
end
