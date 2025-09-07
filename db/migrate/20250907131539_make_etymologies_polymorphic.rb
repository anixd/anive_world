class MakeEtymologiesPolymorphic < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:etymologies, :etymologizable_id) && column_exists?(:etymologies, :etymologizable_type)
      add_reference :etymologies, :etymologizable, polymorphic: true, null: false, index: true
    end

    remove_reference :etymologies, :word, foreign_key: true, if_exists: true
  end
end
