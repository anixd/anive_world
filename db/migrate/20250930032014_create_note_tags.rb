# frozen_string_literal: true

class CreateNoteTags < ActiveRecord::Migration[7.2]
  def change
    create_table :note_tags do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # Уникальность имени тега в пределах одного пользователя
    add_index :note_tags, [:user_id, :name], unique: true
  end
end
