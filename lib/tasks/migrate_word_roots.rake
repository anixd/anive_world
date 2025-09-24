namespace :data do
  desc "Migrates data from word_roots to morphemes. Use DRY_RUN=true for a test run."
  task migrate_word_roots_to_morphemes: :environment do
    is_dry_run = ENV["DRY_RUN"].present? && ENV["DRY_RUN"] != "false"
    logger = setup_logger(is_dry_run)

    log_header(logger, is_dry_run)

    morphemes_to_create = []
    skipped_count = 0

    ActiveRecord::Base.transaction do
      logger.info("🔍 Step 1: Querying all records from 'word_roots'...")
      old_connections = WordRoot.includes(word: :lexeme).all
      logger.info("-> Found #{old_connections.count} connections to migrate.")

      logger.info("\n🔄 Step 2: Processing connections and preparing new morpheme data...")
      old_connections.each do |word_root|
        word = word_root.word
        if word&.lexeme
          morphemes_to_create << {
            lexeme_id: word.lexeme_id,
            morphemable_id: word_root.root_id,
            morphemable_type: "Root",
            position: word_root.position || 1,
            created_at: Time.current,
            updated_at: Time.current
          }
        else
          logger.warn("  - WARNING: Skipping WordRoot ##{word_root.id}. Could not find associated Word or Lexeme.")
          skipped_count += 1
        end
      end
      logger.info("-> Prepared #{morphemes_to_create.count} records for creation. Skipped #{skipped_count}.")

      logger.info("\n🧹 Step 3: Clearing existing 'Root' type morphemes to prevent duplicates...")
      existing_root_morphemes = Morpheme.where(morphemable_type: "Root")
      if is_dry_run
        logger.info("  [DRY RUN] Would delete #{existing_root_morphemes.count} records.")
      else
        deleted_count = existing_root_morphemes.delete_all
        logger.info("  -> Deleted #{deleted_count} records.")
      end

      if morphemes_to_create.any?
        logger.info("\n📦 Step 4: Inserting new morpheme records...")
        if is_dry_run
          logger.info("  [DRY RUN] Would insert #{morphemes_to_create.count} new records.")
        else
          Morpheme.insert_all(morphemes_to_create)
          logger.info("  -> Successfully inserted #{morphemes_to_create.count} records.")
        end
      else
        logger.info("\n🤷 No new records to insert.")
      end

      if is_dry_run
        logger.info("\n⚠️ [DRY RUN] Rolling back transaction. No changes were made to the database.")
        raise ActiveRecord::Rollback
      end
    end

    log_footer(logger, is_dry_run)
  rescue StandardError => e
    logger.error("\n\n❌ AN ERROR OCCURRED: #{e.message}")
    logger.error(e.backtrace.join("\n"))
    log_footer(logger, is_dry_run, error: true)
  end

  private

  def setup_logger(is_dry_run)
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    mode = is_dry_run ? "DRY_RUN" : "LIVE"
    log_file = Rails.root.join("log/migration_word_roots_#{timestamp}_#{mode}.log")
    Logger.new(log_file)
  end

  def log_header(logger, is_dry_run)
    logger.info("=" * 80)
    logger.info(" MIGRATION TASK: word_roots -> morphemes")
    logger.info(" STARTED AT: #{Time.current}")
    logger.info(" MODE: #{is_dry_run ? 'DRY RUN (no changes will be saved)' : 'LIVE (database will be modified)'}")
    logger.info("=" * 80)
    puts "Logging to #{logger.instance_variable_get(:@logdev).dev.path}"
  end

  def log_footer(logger, is_dry_run, error: false)
    status = error ? "FAILED" : "COMPLETED"
    logger.info("\n" + "=" * 80)
    logger.info(" MIGRATION #{status} AT #{Time.current}")
    logger.info("=" * 80)
    puts "Log file available at: #{logger.instance_variable_get(:@logdev).dev.path}"
  end
end
