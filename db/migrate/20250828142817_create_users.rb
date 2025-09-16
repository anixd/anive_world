# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :username, null: false, index: { unique: true }
      t.string :firstname
      t.string :lastname
      t.string :displayname, null: false
      t.string :email, null: false, index: { unique: true }
      t.boolean :active, default: false
      t.string :password_digest

      t.timestamps
    end
  end
end
