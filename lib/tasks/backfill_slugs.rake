namespace :slugs do
  desc "Backfills slugs for models that have been updated to use the Sluggable concern."
  task backfill: :environment do
    puts "Backfilling slugs for Root..."
    Root.find_each(&:save)

    puts "Backfilling slugs for Affix..."
    Affix.find_each(&:save)

    puts "Done."
  end
end
