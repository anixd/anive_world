# Базовый класс для подключения к старой БД
class LegacyBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :anixsite_legacy
end

# Определяем пространство имен для старых моделей
module Legacy
  # Модель для таблицы `anike_word_types`
  class AnikeWordType < LegacyBase
    self.table_name = 'anike_word_types'
  end

  # Модель для таблицы `anike_words`
  class AnikeWord < LegacyBase
    self.table_name = 'anike_words'

    enum language: { anike: 0, drelen: 1, veltari: 2 }

    has_and_belongs_to_many :word_types,
                            class_name: 'Legacy::AnikeWordType',
                            join_table: 'anike_words_word_types',
                            foreign_key: 'anike_word_id',
                            association_foreign_key: 'anike_word_type_id'
  end

  # Модель для таблицы `anike_etymologies`
  class AnikeEtymology < LegacyBase
    self.table_name = 'anike_etymologies'
  end
end
