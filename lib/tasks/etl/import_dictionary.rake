namespace :etl do
  desc "Imports dictionary from legacy AnixSite DB. Use DRY_RUN=true for a test run without saving data."
  task import_dictionary: :environment do
    # Загружаем наши Legacy-модели
    require_relative 'legacy_base'

    is_dry_run = ENV['DRY_RUN'].present? && ENV['DRY_RUN'] != 'false'

    if is_dry_run
      puts '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'
      puts '⚠️  RUNNING IN DRY RUN MODE.'
      puts '⚠️  No changes will be saved to the database.'
      puts '-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-'
    end

    puts '🚀 Starting dictionary migration...'

    # --- ШАГ 0: ПОДГОТОВКА ---
    begin
      author = User.find(1)
      puts "✅ All new records will be authored by: #{author.displayname}"
    rescue ActiveRecord::RecordNotFound
      puts "❌ ERROR: User with ID=1 not found. Please create a user before migrating."
      exit
    end

    begin
      anike_lang = Language.find_by!(code: 'anike')
      puts "✅ Found target language: #{anike_lang.name}"
    rescue ActiveRecord::RecordNotFound
      puts "❌ ERROR: Language with code='anike' not found. Please create it first."
      exit
    end

    pos_id_map = {}
    word_id_map = {}

    # Весь процесс оборачиваем в одну транзакцию для поддержки dry run
    ActiveRecord::Base.transaction do

      # --- Step 1: Parts of Speech migration ---
      puts "\n--> Migrating Parts of Speech (skipping existing)..."
      Legacy::AnikeWordType.find_each do |old_pos|
        # ИЩЕМ запись по уникальному полю `code`.
        # Если не находим, СОЗДАЁМ её с атрибутами из блока.
        # Если находим, просто возвращаем найденную запись.
        new_pos = PartOfSpeech.find_or_create_by!(code: old_pos.code) do |pos|
          pos.name = old_pos.label
          pos.explanation = old_pos.description
          pos.language = anike_lang
          pos.author = author
        end
        # В любом случае, в карту попадёт ID — либо новой, либо уже существующей записи.
        pos_id_map[old_pos.id] = new_pos.id
      end
      puts "Done. Found or created #{pos_id_map.size} parts of speech."

      # --- Step 2: Words, Lexemes, and Roots migration ---
      puts "\n--> Migrating Words, Lexemes, and Roots..."
      words_to_migrate = Legacy::AnikeWord.where(language: 'anike')
      total_count = words_to_migrate.count
      progress = 0

      words_to_migrate.includes(:word_types).find_each do |old_word|
        lexeme = Lexeme.find_or_initialize_by(
          spelling: old_word.word,
          language: anike_lang
        )
        lexeme.author ||= author
        puts "\n ✅ --> Lexeme: #{lexeme.spelling}"
        lexeme.save!

        new_word = lexeme.words.build(
          definition: old_word.translation,
          transcription: old_word.transcription,
          comment: old_word.comment,
          author: author
        )
        puts "\n ✅ --> Word: #{new_word.definition}"
        new_word.save!

        old_pos_ids = old_word.word_type_ids
        new_pos_ids = old_pos_ids.map { |id| pos_id_map[id] }.compact
        new_word.part_of_speech_ids = new_pos_ids

        if old_word.root.present?
          root = Root.find_or_create_by!(text: old_word.root, language: anike_lang) do |r|
            r.author = author
            r.meaning = "TBD (migrated from `#{old_word.word}`)"
          end
          WordRoot.create!(word: new_word, root: root, author: author)
        end

        word_id_map[old_word.id] = new_word.id
        progress += 1
        print "\rProcessed: #{progress}/#{total_count} words..."
      end
      puts "\nDone. Would migrate #{word_id_map.size} words."

      # --- Step 3: Etymologies migration ---
      puts "\n--> Migrating Etymologies..."
      etymology_count = 0
      Legacy::AnikeEtymology.find_each do |old_etymology|
        new_word_id = word_id_map[old_etymology.word_id]
        unless new_word_id
          puts "\n⚠️ WARNING: Skipping etymology for old word ID ##{old_etymology.word_id} (not found in map)."
          next
        end
        Etymology.create!(
          word_id: new_word_id,
          explanation: old_etymology.explanation,
          comment: old_etymology.comment,
          author: author
        )
        etymology_count += 1
      end
      puts "Done. Would migrate #{etymology_count} etymologies."

      # --- Dry run check ---
      if is_dry_run
        puts "\n-*-*-* DRY RUN COMPLETE. ROLLING BACK TRANSACTION. *-*-*-"
        raise ActiveRecord::Rollback
      end
    end # конец транзакции

    if is_dry_run
      puts "\n✅ Dry run finished. No data was changed."
    else
      puts "\n🎉 Dictionary migration completed and committed successfully!"
    end
  end
end
