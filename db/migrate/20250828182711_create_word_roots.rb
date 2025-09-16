# frozen_string_literal: true

class CreateWordRoots < ActiveRecord::Migration[7.2]
  def change
    create_table :word_roots do |t|
      t.references :word, null: false, foreign_key: true
      t.references :root, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.integer :position
      t.datetime :discarded_at, default: nil

      t.timestamps
    end

    add_index :word_roots, :discarded_at
    add_index :word_roots, [:word_id, :root_id], unique: true
  end
end
