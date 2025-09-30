# frozen_string_literal: true

class RefactorSynonymRelations < ActiveRecord::Migration[7.2]
  def up
    # Удаляем старую таблицу
    drop_table :synonym_relations, if_exists: true

    # Создаем новую с правильной структурой
    create_table :synonym_relations do |t|
      t.references :lexeme_1, null: false, foreign_key: { to_table: :lexemes }
      t.references :lexeme_2, null: false, foreign_key: { to_table: :lexemes }
      t.string :comment

      t.timestamps
    end

    # Уникальный индекс, чтобы пара (1, 2) не могла быть создана, если уже есть (1, 2)
    add_index :synonym_relations, [:lexeme_1_id, :lexeme_2_id], unique: true
  end

  def down
    # Этот код позволяет откатить миграцию, воссоздав старую таблицу
    drop_table :synonym_relations, if_exists: true

    create_table :synonym_relations do |t|
      t.references :word, null: false, foreign_key: true
      t.references :synonym, null: false, foreign_key: { to_table: :words }
      t.timestamps
    end
    add_index :synonym_relations, [:word_id, :synonym_id], unique: true
  end
end