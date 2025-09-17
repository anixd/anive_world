namespace :etl do
  desc "Migrates existing etymologies from word_id to a polymorphic association before the schema change."
  task migrate_etymologies_to_polymorphic: :environment do

    # Временная модель для доступа к таблице до миграции
    class TempEtymology < ApplicationRecord
      self.table_name = 'etymologies'
      # Указываем, что модель сама по себе не полиморфная,
      # чтобы Rails не искал колонку `etymologizable_type` раньше времени.
      self.inheritance_column = :_type_disabled
    end

    puts "🚀 Starting etymology data migration..."

    # Добавляем новые колонки вручную, если их ещё нет
    connection = ActiveRecord::Base.connection
    unless connection.column_exists?(:etymologies, :etymologizable_id)
      connection.add_column :etymologies, :etymologizable_id, :bigint
    end
    unless connection.column_exists?(:etymologies, :etymologizable_type)
      connection.add_column :etymologies, :etymologizable_type, :string
    end

    # Создаём временный индекс, чтобы ускорить процесс
    connection.add_index :etymologies, [:etymologizable_type, :etymologizable_id], name: "temp_poly_index", if_not_exists: true

    count = 0
    ActiveRecord::Base.transaction do
      TempEtymology.where(etymologizable_id: nil).find_each do |etymology|
        etymology.update_columns(
          etymologizable_id: etymology.word_id,
          etymologizable_type: 'Word'
        )
        count += 1
      end
    end

    puts "✅ Done. Migrated #{count} etymology records to the new polymorphic columns."

    # Удаляем временный индекс
    connection.remove_index :etymologies, name: "temp_poly_index", if_exists: true
  end
end
