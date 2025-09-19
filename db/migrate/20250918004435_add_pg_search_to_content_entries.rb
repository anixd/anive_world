class AddPgSearchToContentEntries < ActiveRecord::Migration[7.2]
  def up
    # Создаем  кастомную конфигурацию поиска
    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION public.russian_simple (COPY = pg_catalog.simple);
      ALTER TEXT SEARCH CONFIGURATION public.russian_simple
        ALTER MAPPING FOR hword, hword_part, word
        WITH russian_stem, simple;
    SQL

    # столбец для tsvector
    add_column :content_entries, :searchable, :tsvector

    # GIN индекс для скорости
    add_index :content_entries, :searchable, using: :gin, name: 'content_entries_searchable_idx'
  end

  def down
    remove_index :content_entries, name: 'content_entries_searchable_idx'
    remove_column :content_entries, :searchable
    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION IF EXISTS public.russian_simple;
    SQL
  end
end
