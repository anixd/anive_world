namespace :db do
  desc "Purges development & test data (PaperTrail versions, discarded records) from the database."
  task purge_dev_data: :environment do
    is_dry_run = ENV["DRY_RUN"].present? && ENV["DRY_RUN"] != "false"

    if is_dry_run
      puts "\n\e[33m[DRY RUN] No changes will be made to the database.\e[0m"
    else
      puts "\n\e[31m[LIVE RUN] This will permanently delete data from the database.\e[0m"
    end

    puts "=" * 60

    # Step 1: Purge PaperTrail versions
    puts "\n\e[36mSTEP 1: Purging discarded (archived) records...\e[0m"

    discardable_models = [
      Affix, ContentEntry, Etymology, Language, Lexeme, Note, PartOfSpeech, Root, Word
    ]

    total_discarded_purged = 0

    discardable_models.each do |model|
      next unless model.respond_to?(:discarded)

      discarded_scope = model.discarded
      discarded_count = discarded_scope.count

      if discarded_count.zero?
        puts "-> No discarded records found for #{model.name}."
      else
        puts "-> Found #{discarded_count} discarded records for #{model.name} to be permanently deleted."
        unless is_dry_run
          count_before = total_discarded_purged
          discarded_scope.find_each(&:destroy!)
          total_discarded_purged += discarded_count
        end
      end
    end


    # Step 2: Purge discarded records
    puts "\n\e[36mSTEP 2: Purging PaperTrail versions...\e[0m"

    versions_count = PaperTrail::Version.count

    if versions_count.zero?
      puts "-> No versions found to purge."
    else
      puts "-> Found #{versions_count} version records to be deleted."
      unless is_dry_run
        deleted_count = PaperTrail::Version.delete_all
        puts "\e[32m-> Successfully deleted #{deleted_count} records from the 'versions' table.\e[0m"
      end
    end

    unless is_dry_run
      if total_discarded_purged > 0
        puts "\e[32m-> Successfully purged #{total_discarded_purged} discarded records in total.\e[0m"
      end
    end

    unless is_dry_run
      if total_discarded_purged > 0
        puts "\e[32m-> Successfully purged #{total_discarded_purged} discarded records in total.\e[0m"
      end
    end

    puts "\n" + "=" * 60
    puts "\e[32m✅ Cleanup task finished.\e[0m"
  end
end
