class CreateTimelineCalendars < ActiveRecord::Migration[7.2]
  def change
    create_table :timeline_calendars do |t|
      t.string :name, null: false
      t.string :epoch_name
      t.integer :absolute_year_of_epoch, null: false
      t.text :description

      t.timestamps
    end
  end
end
