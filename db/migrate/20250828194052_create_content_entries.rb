class CreateContentEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :content_entries do |t|
      # ОБЩИЕ ПОЛЯ
      t.string :type, null: false
      t.string :title, null: false
      t.text :body
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :slug, null: false
      t.datetime :published_at
      t.datetime :discarded_at

      # СПЕЦИФИЧНЫЕ ПОЛЯ ДЛЯ НАСЛЕДНИКОВ

      # HistoryEntry
      t.string :world_date
      t.integer :timeline_position

      # Character
      t.string :life_status
      t.string :birth_date
      t.string :death_date

      # Location (ссылка на саму себя для иерархии)
      t.references :parent_location, foreign_key: { to_table: :content_entries }

      # GrammarRule & PhonologyArticle
      t.string :rule_code
      t.references :language, foreign_key: true

      t.timestamps
    end

    add_index :content_entries, :discarded_at
    add_index :content_entries, :type

    # Главный индекс для уникальности slug только среди "soft deleted записей
    add_index :content_entries, :slug, unique: true, where: "discarded_at IS NULL"
  end
end
