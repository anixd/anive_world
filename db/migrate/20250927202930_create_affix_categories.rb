# frozen_string_literal: true

class CreateAffixCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :affix_categories do |t|
      t.references :language, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.timestamps

      t.index [:language_id, :code], unique: true
      t.index [:language_id, :name], unique: true
    end
  end
end
