class CreateEtymologies < ActiveRecord::Migration[7.2]
  def change
    create_table :etymologies do |t|
      t.references :word, null: false, foreign_key: true, index: { unique: true }
      t.text :explanation, null: false
      t.text :comment

      t.timestamps
    end
  end
end
