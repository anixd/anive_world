class AddPublishableToLinguisticModels < ActiveRecord::Migration[7.2]
  def change
    add_column :lexemes, :published_at, :datetime
    add_index :lexemes, :published_at

    add_column :roots, :published_at, :datetime
    add_index :roots, :published_at

    add_column :affixes, :published_at, :datetime
    add_index :affixes, :published_at
  end
end
