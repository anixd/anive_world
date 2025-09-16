# frozen_string_literal: true

class CreateNotes < ActiveRecord::Migration[7.2]
  def change
    create_table :notes do |t|
      t.string :title, null: false
      t.text :body
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.boolean :is_public_for_team, default: false, null: false
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :notes, :discarded_at
  end
end
