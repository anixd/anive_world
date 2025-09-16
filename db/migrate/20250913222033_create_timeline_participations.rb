# frozen_string_literal: true

class CreateTimelineParticipations < ActiveRecord::Migration[7.2]
  def change
    create_table :timeline_participations do |t|
      t.string :role
      t.references :history_entry, null: false, foreign_key: { to_table: :content_entries }
      t.references :participant, polymorphic: true, null: false

      t.timestamps
    end
  end
end
