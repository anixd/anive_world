class AddSearchTriggerToContentEntries < ActiveRecord::Migration[7.2]
  def up
    # Создаём функцию для обновления searchable столбца
    execute <<-SQL
      CREATE OR REPLACE FUNCTION update_content_entries_searchable()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.searchable := 
          setweight(to_tsvector('public.russian_simple', coalesce(NEW.title, '')), 'A') ||
          setweight(to_tsvector('public.russian_simple', coalesce(NEW.body, '')), 'B') ||
          setweight(to_tsvector('public.russian_simple', coalesce(NEW.extract, '')), 'C') ||
          setweight(to_tsvector('public.russian_simple', coalesce(NEW.annotation, '')), 'D');
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    # Создаём триггер
    execute <<-SQL
      CREATE TRIGGER update_searchable_trigger
      BEFORE INSERT OR UPDATE OF title, body, extract, annotation
      ON content_entries
      FOR EACH ROW
      EXECUTE FUNCTION update_content_entries_searchable();
    SQL

    # Заполняем существующие записи
    execute <<-SQL
      UPDATE content_entries 
      SET searchable = 
        setweight(to_tsvector('public.russian_simple', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('public.russian_simple', coalesce(body, '')), 'B') ||
        setweight(to_tsvector('public.russian_simple', coalesce(extract, '')), 'C') ||
        setweight(to_tsvector('public.russian_simple', coalesce(annotation, '')), 'D');
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS update_searchable_trigger ON content_entries;"
    execute "DROP FUNCTION IF EXISTS update_content_entries_searchable();"
  end
end
