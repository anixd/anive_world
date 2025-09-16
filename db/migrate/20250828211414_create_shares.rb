# frozen_string_literal: true

class CreateShares < ActiveRecord::Migration[7.2]
  def change
    create_table :shares do |t|
      t.references :user, null: false, foreign_key: true
      t.references :shareable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :shares, [:user_id, :shareable_id, :shareable_type], unique: true, name: 'index_shares_on_user_and_shareable'
  end
end
