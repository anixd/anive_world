class CreateLanguages < ActiveRecord::Migration[7.2]
  def change
    create_table :languages do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.references :parent_language, foreign_key: { to_table: :languages }

      t.timestamps
    end
    add_index :languages, :name, unique: true
    add_index :languages, :code, unique: true
  end
end
