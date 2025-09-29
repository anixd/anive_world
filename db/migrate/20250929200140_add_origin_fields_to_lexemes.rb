# frozen_string_literal: true

class AddOriginFieldsToLexemes < ActiveRecord::Migration[7.2]
  def change
    add_column :lexemes, :origin_type, :integer
    add_reference :lexemes, :origin_language, foreign_key: { to_table: :languages }, null: true
  end
end
