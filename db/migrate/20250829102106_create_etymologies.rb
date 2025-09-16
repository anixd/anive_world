# frozen_string_literal: true

class CreateEtymologies < ActiveRecord::Migration[7.2]
  def change
    create_table :etymologies do |t|
      t.references :word, null: false, foreign_key: true, index: { unique: true }
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.text :explanation, null: false
      t.text :comment
      t.datetime :discarded_at, default: nil

      t.timestamps
    end

    add_index :etymologies, :discarded_at
  end
end
