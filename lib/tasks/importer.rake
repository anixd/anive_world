require 'logger'

namespace :importer do
  # --- Main Task ---
  desc "Full data migration from AnixSite. Runs all migration tasks."
  task full_migration: :environment do
    require_relative 'etl/legacy_base'

    logger, is_dry_run = setup_logger("full_migration")
    logger.info("=================================================")
    logger.info("🚀 Starting FULL data migration...")
    logger.info("=================================================")

    Rake::Task["importer:clear_all"].invoke(logger, is_dry_run)
    Rake::Task["importer:linguistic_core"].invoke(logger, is_dry_run)
    Rake::Task["importer:content_entries"].invoke(logger, is_dry_run)
    Rake::Task["importer:notes"].invoke(logger, is_dry_run)
    Rake::Task["importer:reindex_wikilinks"].invoke(logger, is_dry_run)

    logger.info("\n=================================================")
    logger.info("✅ FULL MIGRATION SUCCESSFULLY COMPLETED!")
    log_file_path(logger)
  end

  desc "Migrates the linguistic core (Dictionary, Roots, etc)."
  task :linguistic_core, [:logger, :is_dry_run] => :environment do |t, args|
    require_relative 'etl/legacy_base'

    logger, is_dry_run = args[:logger] || setup_logger("linguistic_core")
    log_header(logger: logger, title: "Migrating Linguistic Core", is_dry_run: is_dry_run)

    author = get_author(logger: logger)
    clear_tables(
      logger: logger,
      models: [Word, PartOfSpeech, Root, Affix, Etymology, Lexeme, Language],
      join_tables: ["parts_of_speech_words", "word_roots"],
      is_dry_run: is_dry_run
    )

    languages = setup_languages(logger: logger, author: author, is_dry_run: is_dry_run)
    anike_lang = languages.find { |l| l.code == 'anike' }
    pos_map = migrate_parts_of_speech(logger: logger, languages: languages, author: author, is_dry_run: is_dry_run)
    root_map = migrate_roots(logger: logger, language: anike_lang, author: author, is_dry_run: is_dry_run)
    migrate_dictionary(logger: logger, language: anike_lang, author: author, pos_map: pos_map, root_map: root_map, is_dry_run: is_dry_run)

    log_footer(logger: logger, title: "Linguistic Core migration")
  end

  desc "Migrates content entries (Articles, History)."
  task :content_entries, [:logger, :is_dry_run] => :environment do |t, args|
    require_relative 'etl/legacy_base'

    logger, is_dry_run = args[:logger] || setup_logger("content_entries")
    log_header(logger: logger, title: "Migrating Content Entries", is_dry_run: is_dry_run)
    author = get_author(logger: logger)
    clear_tables(logger: logger, models: [ContentEntry], is_dry_run: is_dry_run)

    logger.info("\n--> Migrating Articles...")
    total = Legacy::AnikeArticle.count
    processed = 0
    Legacy::AnikeArticle.find_each do |old|
      attrs = { title: old.title, body: old.body, annotation: old.annotation, extract: old.extract, author: author,
                published_at: old.published ? old.updated_at : nil, created_at: old.created_at, updated_at: old.updated_at }
      log_creation(logger: logger, type: "Article", name: old.title, is_dry_run: is_dry_run)
      Article.create!(attrs) unless is_dry_run
      processed += 1
    end
    logger.info("Done. Processed #{processed}/#{total} articles.")

    logger.info("\n--> Migrating History Entries...")
    total = Legacy::AnikeHistoryEntry.count
    processed = 0
    Legacy::AnikeHistoryEntry.find_each do |old|
      attrs = { title: old.title, body: old.body, display_date: old.world_date, author: author,
                published_at: old.published ? old.updated_at : nil, created_at: old.created_at, updated_at: old.updated_at }
      log_creation(logger: logger, type: "HistoryEntry", name: old.title, is_dry_run: is_dry_run)
      HistoryEntry.create!(attrs) unless is_dry_run
      processed += 1
    end
    logger.info("Done. Processed #{processed}/#{total} history entries.")

    log_footer(logger: logger, title: "Content Entries migration")
  end

  desc "Migrates notes from Anike::Note."
  task :notes, [:logger, :is_dry_run] => :environment do |t, args|
    require_relative 'etl/legacy_base'

    logger, is_dry_run = args[:logger] || setup_logger("notes")
    log_header(logger: logger, title: "Migrating Notes", is_dry_run: is_dry_run)
    author = get_author(logger: logger)
    clear_tables(logger: logger, models: [Note], is_dry_run: is_dry_run)

    logger.info("\n--> Migrating Notes...")
    total = Legacy::AnikeNote.count
    processed = 0
    Legacy::AnikeNote.find_each do |old|
      attrs = { title: old.title, body: old.body, author: author, created_at: old.created_at, updated_at: old.updated_at }
      log_creation(logger: logger, type: "Note", name: old.title, is_dry_run: is_dry_run)
      Note.create!(attrs) unless is_dry_run
      processed += 1
    end
    logger.info("Done. Processed #{processed}/#{total} notes.")

    log_footer(logger: logger, title: "Notes migration")
  end

  desc "Clears all migratable data from the database."
  task :clear_all, [:logger, :is_dry_run] => :environment do |t, args|
    logger, is_dry_run = args[:logger] || setup_logger("clear_all")
    log_header(logger: logger, title: "Clearing All Target Tables", is_dry_run: is_dry_run)
    clear_tables(
      logger: logger,
      models: [Wikilink, SlugRedirect, Word, PartOfSpeech, Root, Affix, Etymology, Lexeme, ContentEntry, Note, Language],
      join_tables: ["parts_of_speech_words", "word_roots"],
      is_dry_run: is_dry_run
    )
    log_footer(logger: logger, title: "Clearing tables")
  end

  desc "Re-indexes all wikilinks for migrated content."
  task :reindex_wikilinks, [:logger, :is_dry_run] => :environment do |t, args|
    logger, is_dry_run = args[:logger] || setup_logger("reindex_wikilinks")
    log_header(logger: logger, title: "Re-indexing Wikilinks", is_dry_run: is_dry_run)

    if is_dry_run
      logger.info("--> [DRY RUN] Would clear all wikilinks and re-index ContentEntry, Word, Root, Affix, Etymology.")
    else
      logger.info("--> Clearing old wikilinks...")
      Wikilink.delete_all
      logger.info("Done.")

      models_to_index = [ContentEntry, Word, Root, Affix, Etymology]
      models_to_index.each do |model|
        logger.info("\n--> Indexing links in #{model.name}...")
        total = model.count
        processed = 0
        model.find_each do |record|
          WikilinkIndexer.call(record)
          processed += 1
        end
        logger.info("Done. Indexed #{processed}/#{total} records in #{model.name}.")
      end
    end

    log_footer(logger: logger, title: "Re-indexing")
  end
end

private

def setup_logger(task_name)
  is_dry_run = ENV["DRY_RUN"].present?
  timestamp = Time.current.strftime("%Y-%m-%d_%H%M%S")
  filename = "migration_#{task_name}_#{timestamp}#{is_dry_run ? '_DRY_RUN' : ''}.log"
  log_path = Rails.root.join('log', filename)
  logger = Logger.new(log_path)
  logger.formatter = ->(severity, datetime, progname, msg) { "#{msg}\n" }
  puts "Logging to #{log_path}"
  [logger, is_dry_run]
end

def log_header(logger:, title:, is_dry_run:)
  logger.info("=" * 60)
  logger.info("Rake Task: #{title}")
  logger.info("Mode: #{is_dry_run ? 'DRY RUN (no changes will be saved)' : 'LIVE (writing to DB)'}")
  logger.info("Timestamp: #{Time.current}")
  logger.info("=" * 60)
end

def log_footer(logger:, title:)
  logger.info("\n✅ Finished: #{title}.")
  log_file_path(logger)
end

def log_file_path(logger)
  if logger.instance_variable_get(:@logdev).dev.respond_to?(:path)
    logger.info("📄 Log file saved at: #{logger.instance_variable_get(:@logdev).dev.path}")
  end
end

def get_author(logger:)
  User.find(1)
rescue ActiveRecord::RecordNotFound
  logger.error("❌ ERROR: User with ID=1 not found. Please ensure this user exists.")
  abort("User with ID=1 not found.")
end

def clear_tables(logger:, models: [], join_tables: [], is_dry_run: false)
  logger.info("\n--> Clearing tables...")
  connection = ActiveRecord::Base.connection

  # Clear join tables first to avoid foreign key violations
  join_tables.each do |table_name|
    log_action(logger: logger, action: "Truncating join table", subject: table_name, is_dry_run: is_dry_run)
    connection.execute("TRUNCATE TABLE #{connection.quote_table_name(table_name)} RESTART IDENTITY CASCADE;") unless is_dry_run
  end

  # Clear model tables
  models.each do |model|
    table_name = model.table_name
    log_action(logger: logger, action: "Truncating model table", subject: table_name, is_dry_run: is_dry_run)
    connection.execute("TRUNCATE TABLE #{connection.quote_table_name(table_name)} RESTART IDENTITY CASCADE;") unless is_dry_run
  end

  logger.info("Done.")
end

def setup_languages(logger:, author:, is_dry_run:)
  logger.info("\n--> Setting up languages...")
  langs_to_ensure = [{ name: "Anik'e", code: 'anike' }, { name: "Drelen", code: 'drelen' }, { name: "Vel'tari", code: 'veltari' }]
  created_languages = []
  langs_to_ensure.each do |attrs|
    lang = Language.find_by(code: attrs[:code])
    unless lang
      log_creation(logger: logger, type: "Language", name: attrs[:name], is_dry_run: is_dry_run)
      lang = Language.new(attrs.merge(author: author))
      lang.save! unless is_dry_run
    end
    created_languages << lang
  end
  logger.info("Done.")
  created_languages
end

def migrate_parts_of_speech(logger:, languages:, author:, is_dry_run:)
  logger.info("\n--> Migrating Parts of Speech...")
  pos_map = {}
  service_codes = ['афф.', 'кор.']
  Legacy::AnikeWordType.where.not(code: service_codes).find_each do |old_pos|
    new_pos_for_anike = nil
    languages.each do |lang|
      attrs = { language: lang, name: old_pos.label, code: old_pos.code, explanation: old_pos.description, author: author }
      log_creation(logger: logger, type: "PartOfSpeech", name: "'#{old_pos.label}' for #{lang.code}", is_dry_run: is_dry_run)
      new_pos = PartOfSpeech.create!(attrs) unless is_dry_run
      new_pos_for_anike = new_pos if lang.code == 'anike'
    end
    pos_map[old_pos.id] = new_pos_for_anike.id if new_pos_for_anike
  end
  logger.info("Done.")
  pos_map
end

def migrate_roots(logger:, language:, author:, is_dry_run:)
  logger.info("\n--> Migrating Roots...")
  root_data_map = {}
  logger.info("    Step 1: Gathering simple root mentions...")
  Legacy::AnikeWord.where.not(root: [nil, ""]).pluck(:root).each do |root_string|
    root_string.split('+').map(&:strip).reject(&:blank?).each { |text| root_data_map[text.downcase] ||= {} }
  end

  logger.info("    Step 2: Enriching with data from 'word-roots'...")
  root_word_type = Legacy::AnikeWordType.find_by(code: 'кор.')
  if root_word_type
    root_word_type.words.includes(:etymology).find_each do |word_as_root|
      root_text = word_as_root.word.downcase
      root_data_map[root_text] = { meaning: word_as_root.translation, etymology_record: word_as_root.etymology }
    end
  end

  logger.info("    Step 3: Creating canonical Root records...")
  root_id_map = {}
  root_data_map.each do |root_text, data|
    attrs = { text: root_text, meaning: data[:meaning], language: language, author: author, published_at: Time.current }
    log_creation(logger: logger, type: "Root", name: root_text, is_dry_run: is_dry_run)
    new_root = Root.new(attrs)
    unless is_dry_run
      new_root.save!
      if data[:etymology_record]
        new_root.create_etymology!(explanation: data[:etymology_record].explanation, comment: data[:etymology_record].comment, author: author)
      end
    end
    root_id_map[root_text] = new_root.id
  end
  logger.info("Done. Processed #{root_id_map.size} unique roots.")
  root_id_map
end

def migrate_dictionary(logger:, language:, author:, pos_map:, root_map:, is_dry_run:)
  logger.info("\n--> Migrating Dictionary (Affixes, Lexemes, Words)...")
  affix_type_id = Legacy::AnikeWordType.find_by(code: 'афф.')&.id
  root_type_id = Legacy::AnikeWordType.find_by(code: 'кор.')&.id
  total = Legacy::AnikeWord.count
  processed = 0
  log_interval = [(total / 10), 1].max # Log progress every 10%

  Legacy::AnikeWord.includes(:word_types, :etymology).find_each do |old_word|
    word_type_ids = old_word.word_type_ids
    if word_type_ids.include?(affix_type_id)
      attrs = { text: old_word.word, meaning: old_word.translation, affix_type: 'suffix', language: language, author: author, published_at: (old_word.published ? old_word.updated_at : nil) }
      log_creation(logger: logger, type: "Affix", name: old_word.word, is_dry_run: is_dry_run)
      Affix.create!(attrs) unless is_dry_run
    elsif word_type_ids.include?(root_type_id)
      # Skip, handled in migrate_roots
    else
      log_creation(logger: logger, type: "Lexeme", name: old_word.word, is_dry_run: is_dry_run)
      lexeme = nil
      lexeme = Lexeme.find_or_create_by!(spelling: old_word.word, language: language) { |l| l.author = author } unless is_dry_run
      if lexeme
        word_attrs = { type: 'AnikeWord', definition: old_word.translation, transcription: old_word.transcription, comment: old_word.comment, author: author, created_at: old_word.created_at, updated_at: old_word.updated_at }
        new_word = lexeme.words.build(word_attrs)
        new_word.save! unless is_dry_run
        if new_word&.persisted? || is_dry_run
          new_pos_ids = old_word.word_type_ids.map { |id| pos_map[id] }.compact
          new_word.part_of_speech_ids = new_pos_ids if new_pos_ids.any? && !is_dry_run
          if old_word.root.present?
            root_texts = old_word.root.split('+').map { |r| r.strip.downcase }
            root_texts.each_with_index do |root_text, index|
              root_id = root_map[root_text]
              next unless root_id

              if is_dry_run
                # `new_word` в dry_run режиме не существует, поэтому используем `old_word.word`
                log_action(logger: logger, action: "Link Word '#{old_word.word}' to Root", subject: "'#{root_text}'", is_dry_run: is_dry_run)
              else
                WordRoot.create!(
                  word: new_word,
                  root_id: root_id,
                  author: author,
                  position: index + 1
                )
              end
            end
          end
          if old_word.etymology
            etymology_attrs = { explanation: old_word.etymology.explanation, comment: old_word.etymology.comment, author: author }
            new_word.create_etymology!(etymology_attrs) unless is_dry_run
          end
        end
      end
    end
    processed += 1
    logger.info("    Processed #{processed}/#{total} dictionary entries...") if processed > 0 && processed % log_interval == 0
  end
  logger.info("Done. Processed #{processed} total entries.")
end

def log_action(logger:, action:, subject:, is_dry_run:)
  prefix = is_dry_run ? "[DRY RUN] Would " : ""
  logger.info("    #{prefix}#{action}: #{subject}")
end

def log_creation(logger:, type:, name:, is_dry_run:)
  log_action(logger: logger, action: "Create #{type}", subject: "'#{name}'", is_dry_run: is_dry_run)
end
