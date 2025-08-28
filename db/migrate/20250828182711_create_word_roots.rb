class CreateWordRoots < ActiveRecord::Migration[7.2]
  def change
    create_table :word_roots do |t|
      t.references :word, null: false, foreign_key: true
      t.references :root, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end

    add_index :word_roots, [:word_id, :root_id], unique: true
  end
end
