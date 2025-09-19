class AddSlugToRootsAndAffixes < ActiveRecord::Migration[7.2]
  def change
    add_column :roots, :slug, :string
    add_column :affixes, :slug, :string

    # Add indexes for uniqueness within a language, respecting soft-deletes
    add_index :roots, [:slug, :language_id], unique: true, where: "discarded_at IS NULL"
    add_index :affixes, [:slug, :language_id], unique: true, where: "discarded_at IS NULL"
  end
end
