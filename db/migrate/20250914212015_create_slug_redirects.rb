class CreateSlugRedirects < ActiveRecord::Migration[7.2]
  def change
    create_table :slug_redirects do |t|
      t.string :old_slug, null: false
      t.references :sluggable, polymorphic: true, null: false

      t.timestamps
    end
    add_index :slug_redirects, :old_slug
  end
end
