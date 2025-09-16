# frozen_string_literal: true

class CreateTimelineEras < ActiveRecord::Migration[7.2]
  def change
    create_table :timeline_eras do |t|
      t.string :name, null: false
      t.integer :order_index
      t.integer :start_absolute_year
      t.integer :end_absolute_year
      t.references :calendar, null: false, foreign_key: { to_table: :timeline_calendars }, index: true

      t.timestamps
    end
  end
end
