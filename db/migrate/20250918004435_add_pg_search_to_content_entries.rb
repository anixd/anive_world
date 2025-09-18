class AddPgSearchToContentEntries < ActiveRecord::Migration[7.2]
  def up
    # 1. Создаем нашу кастомную конфигурацию поиска.
    # Она сначала пытается применить русский словарь (с морфологией),
    # а если слово не опознано (например, на anik'e), использует 'simple' (просто приводит к lowercase).
    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION public.russian_simple (COPY = pg_catalog.simple);
      ALTER TEXT SEARCH CONFIGURATION public.russian_simple
        ALTER MAPPING FOR hword, hword_part, word
        WITH russian_stem, simple;
    SQL

    # 2. Добавляем столбец для хранения "поискового документа" (tsvector).
    add_column :content_entries, :searchable, :tsvector

    # 3. Создаем GIN индекс для этого столбца. Это критически важно для скорости поиска.
    add_index :content_entries, :searchable, using: :gin, name: 'content_entries_searchable_idx'

    # 4. Создаем триггер, который будет автоматически обновлять столбец `searchable`
    # при любом изменении полей `title` или `body`.
    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON content_entries FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(searchable, 'public.russian_simple', title, body);
    SQL
  end

  def down
    # Определяем шаги для отката миграции в обратном порядке.
    execute <<-SQL
      DROP TRIGGER IF EXISTS tsvectorupdate ON content_entries;
    SQL
    remove_index :content_entries, name: 'content_entries_searchable_idx'
    remove_column :content_entries, :searchable
    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION IF EXISTS public.russian_simple;
    SQL
  end
end
