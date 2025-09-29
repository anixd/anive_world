# frozen_string_literal: true

class RemoveOriginFieldsFromWords < ActiveRecord::Migration[7.2]
  def change
    remove_column :words, :origin_type, :bigint
    remove_column :words, :origin_word_id, :bigint
  end
end
