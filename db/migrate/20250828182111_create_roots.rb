# frozen_string_literal: true

class CreateRoots < ActiveRecord::Migration[7.2]
  def change
    create_table :roots do |t|
      t.string :text
      t.references :language, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.text :meaning
      t.datetime :discarded_at, default: nil

      t.timestamps
    end
    add_index :roots, :discarded_at
    add_index :roots, [:text, :language_id], unique: true
  end
end
