# frozen_string_literal: true

class AddLanguageToPartOfSpeech < ActiveRecord::Migration[7.2]
  def change
    # 1. Находим "язык по умолчанию", к которому отнесем все существующие части речи
    # default_language = Language.find_by(code: 'anike')

    # 2. Добавляем колонку, но ПОКА разрешаем ей быть NULL
    add_reference :parts_of_speech, :language, foreign_key: true, null: false

    # 3. Прописываем язык по умолчанию для всех существующих записей
    # Этот блок выполнится только при накате миграции (up)
    # reversible do |dir|
    #   dir.up do
    #     PartOfSpeech.where(language_id: nil).update_all(language_id: default_language.id)
    #   end
    # end

    # 4. Теперь, когда у всех записей есть значение,
    # безопасно добавляем ограничение NOT NULL
    # change_column_null :parts_of_speech, :language_id, null: false
  end
end
