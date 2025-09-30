# frozen_string_literal: true

class CreateNoteTaggings < ActiveRecord::Migration[7.2]
  def change
    create_table :note_taggings do |t|
      t.references :note, null: false, foreign_key: true
      t.references :note_tag, null: false, foreign_key: true

      t.timestamps
    end

    # Одна заметка может иметь один и тот же тег только один раз
    add_index :note_taggings, [:note_id, :note_tag_id], unique: true
  end
end
