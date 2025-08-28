class CreateRoots < ActiveRecord::Migration[7.2]
  def change
    create_table :roots do |t|
      t.string :text
      t.references :language, null: false, foreign_key: true
      t.text :meaning

      t.timestamps
    end
    add_index :roots, [:text, :language_id], unique: true
  end
end
