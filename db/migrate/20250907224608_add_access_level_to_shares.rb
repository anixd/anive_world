class AddAccessLevelToShares < ActiveRecord::Migration[7.2]
  def change
    add_column :shares, :access_level, :integer, default: 0, null: false
  end
end
