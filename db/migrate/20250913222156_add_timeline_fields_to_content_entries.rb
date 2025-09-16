# frozen_string_literal: true

class AddTimelineFieldsToContentEntries < ActiveRecord::Migration[7.2]
  def change
    add_reference :content_entries, :era, foreign_key: { to_table: :timeline_eras }, index: true, null: true
    add_column :content_entries, :absolute_year, :integer
    add_column :content_entries, :display_date, :string
    add_index :content_entries, :absolute_year

    remove_column :content_entries, :world_date, :string
    remove_column :content_entries, :timeline_position, :integer
  end
end
