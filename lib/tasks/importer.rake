class LegacyRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :legacy
end

module Legacy
end

# Определяем классы, соответствующие таблицам в старой БД
Legacy.const_set("AnikeWord", Class.new(LegacyRecord) {
  self.table_name = "anike_words"
  has_and_belongs_to_many :word_types, class_name: "Legacy::AnikeWordType", join_table: "anike_words_word_types", foreign_key: "anike_word_id", association_foreign_key: "anike_word_type_id"
  has_one :etymology, class_name: "Legacy::AnikeEtymology", foreign_key: "word_id"
})
Legacy.const_set("AnikeWordType", Class.new(LegacyRecord) {
  self.table_name = "anike_word_types"
  has_and_belongs_to_many :words, class_name: "Legacy::AnikeWord", join_table: "anike_words_word_types", foreign_key: "anike_word_type_id", association_foreign_key: "anike_word_id"
})
Legacy.const_set("AnikeEtymology", Class.new(LegacyRecord) { self.table_name = "anike_etymologies" })
Legacy.const_set("AnikeArticle", Class.new(LegacyRecord) { self.table_name = "anike_articles" })
Legacy.const_set("AnikeHistoryEntry", Class.new(LegacyRecord) { self.table_name = "anike_history_entries" })
# --- КОНЕЦ ИСПРАВЛЕНИЯ ---


namespace :importer do
  desc "Полная миграция данных из старого приложения AnixSite в AniveWorld"
  task full_migration: :environment do
    puts "Начинаем полную миграцию данных..."
    puts "===================================="

    # Метод setup_legacy_models больше не нужен, так как все определено выше.

    clear_current_database

    # --- Этап 1: Базовые сущности ---
    puts "\n[1/5] Создаем языки..."
    languages = setup_languages
    anike_lang = languages.find { |l| l.code == "anike" }

    puts "\n[2/5] Мигрируем части речи..."
    pos_map = migrate_parts_of_speech(languages)

    puts "\n[3/5] Собираем и создаем канонические корни..."
    root_map = migrate_roots(anike_lang)

    # --- Этап 2: Контент ---
    puts "\n[4/5] Мигрируем основной контент (статьи, история) и словарь..."
    migrate_content_and_dictionary(anike_lang, pos_map, root_map)

    # --- Этап 3: Пост-обработка ---
    puts "\n[5/5] Запускаем переиндексацию вики-ссылок..."
    reindex_wikilinks

    puts "\n===================================="
    puts "✅ Миграция успешно завершена!"
  end

  private

  # --- Методы-помощники ---

  def clear_current_database
    puts "--> Очистка таблиц со сбросом счетчиков ID..."

    models_to_truncate = [
      "parts_of_speech_words", # join-таблицы первыми
      Wikilink, SlugRedirect, WordTranslation, WordRoot, SynonymRelation,
      Word, PartOfSpeech, Root, Affix, Etymology, Lexeme,
      ContentEntry, Language, Note
    ]

    connection = ActiveRecord::Base.connection
    models_to_truncate.each do |model|
      table_name = model.is_a?(String) ? model : model.table_name
      puts "    - Очистка #{table_name}"
      connection.execute("TRUNCATE TABLE #{connection.quote_table_name(table_name)} RESTART IDENTITY CASCADE;")
    end
  end

  def setup_languages
    puts "--> Проверка и создание языков..."
    langs_to_ensure = [
      { name: "Anik'e", code: "anike" },
      { name: "Drelen", code: "drelen" },
      { name: "Vel'tari", code: "veltari" }
    ]
    langs_to_ensure.each do |lang_attrs|
      Language.find_or_create_by!(code: lang_attrs[:code]) do |lang|
        lang.name = lang_attrs[:name]
        lang.author_id = 1
      end
    end
    Language.all.to_a
  end

  def migrate_parts_of_speech(languages)
    pos_map = {}
    service_codes = ["афф.", "кор."]
    Legacy::AnikeWordType.where.not(code: service_codes).find_each do |old_pos|
      new_pos_for_anike = nil
      languages.each do |lang|
        new_pos = PartOfSpeech.create!(
          language: lang,
          name: old_pos.label,
          code: old_pos.code,
          explanation: old_pos.description,
          author_id: 1
        )
        new_pos_for_anike = new_pos if lang.code == "anike"
      end
      pos_map[old_pos.id] = new_pos_for_anike.id if new_pos_for_anike
    end
    pos_map
  end

  def migrate_roots(anike_lang)
    root_data_map = {}
    delimiter = "+"

    puts "--> Проход 1: Сбор простых упоминаний корней..."
    Legacy::AnikeWord.where.not(root: [nil, ""]).pluck(:root).each do |root_string|
      root_string.split(delimiter).map(&:strip).reject(&:blank?).each do |root_text|
        root_data_map[root_text.downcase] ||= {}
      end
    end

    puts "--> Проход 2: Обогащение данными из слов-корней..."
    root_word_type = Legacy::AnikeWordType.find_by(code: "кор.")
    if root_word_type
      root_word_type.words.includes(:etymology).find_each do |word_as_root|
        root_text = word_as_root.word.downcase
        root_data_map[root_text] = {
          meaning: word_as_root.translation,
          etymology_record: word_as_root.etymology
        }
      end
    end

    puts "--> Создание канонических записей Root..."
    root_id_map = {}
    root_data_map.each do |root_text, data|
      new_root = Root.create!(
        text: root_text,
        meaning: data[:meaning],
        language: anike_lang,
        author_id: 1,
        published_at: Time.current
      )
      if data[:etymology_record]
        new_root.create_etymology!(
          explanation: data[:etymology_record].explanation,
          comment: data[:etymology_record].comment,
          author_id: 1,
          published_at: Time.current
        )
      end
      root_id_map[root_text] = new_root.id
    end
    root_id_map
  end

  def migrate_content_and_dictionary(anike_lang, pos_map, root_map)
    puts "--> Миграция статей Anike::Article..."
    Legacy::AnikeArticle.find_each do |old_article|
      Article.create!(
        title: old_article.title,
        body: old_article.body,
        annotation: old_article.annotation,
        extract: old_article.extract,
        author_id: 1,
        published_at: old_article.published ? Time.current : nil,
        created_at: old_article.created_at,
        updated_at: old_article.updated_at
      )
    end

    puts "--> Миграция Anike::HistoryEntry..."
    Legacy::AnikeHistoryEntry.find_each do |old_entry|
      HistoryEntry.create!(
        title: old_entry.title,
        body: old_entry.body,
        display_date: old_entry.world_date,
        author_id: 1,
        published_at: old_entry.published ? Time.current : nil,
        created_at: old_entry.created_at,
        updated_at: old_entry.updated_at
      )
    end

    puts "--> Миграция словаря Anike::Word..."
    affix_word_type_id = Legacy::AnikeWordType.find_by(code: "афф.")&.id
    root_word_type_id = Legacy::AnikeWordType.find_by(code: "кор.")&.id
    delimiter = "+"

    Legacy::AnikeWord.includes(:word_types, :etymology).find_each do |old_word|
      is_affix = old_word.word_type_ids.include?(affix_word_type_id)
      is_root = old_word.word_type_ids.include?(root_word_type_id)

      if is_affix
        Affix.create!(
          text: old_word.word,
          meaning: old_word.translation,
          affix_type: "suffix",
          language: anike_lang,
          author_id: 1,
          published_at: old_word.published ? Time.current : nil
        )
      elsif is_root
        next
      else
        lexeme = Lexeme.find_or_create_by!(
          spelling: old_word.word,
          language: anike_lang
        ) { |l| l.author_id = 1 }

        new_word = lexeme.words.create!(
          definition: old_word.translation,
          transcription: old_word.transcription,
          comment: old_word.comment,
          author_id: 1,
          published_at: old_word.published ? Time.current : nil,
          created_at: old_word.created_at,
          updated_at: old_word.updated_at
        )

        new_pos_ids = old_word.word_type_ids.map { |id| pos_map[id] }.compact
        new_word.part_of_speech_ids = new_pos_ids if new_pos_ids.any?

        if old_word.root.present?
          root_texts = old_word.root.split(delimiter).map { |r| r.strip.downcase }
          root_ids = root_texts.map { |text| root_map[text] }.compact
          new_word.root_ids = root_ids if root_ids.any?
        end

        if old_word.etymology
          new_word.create_etymology!(
            explanation: old_word.etymology.explanation,
            comment: old_word.etymology.comment,
            author_id: 1,
            published_at: old_word.published ? Time.current : nil
          )
        end
      end
    end
  end

  def reindex_wikilinks
    models_to_index = [ContentEntry, Word, Root, Affix, Etymology]
    models_to_index.each do |model|
      puts "--> Индексация ссылок в #{model.name}..."
      model.find_each { |record| WikilinkIndexer.call(record) }
    end
  end
end
