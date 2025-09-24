# frozen_string_literal: true

class DropWordRoots < ActiveRecord::Migration[7.2]
  def up
    drop_table :word_roots
  end

  def down
    # Эту миграцию откатывать не предполагается,
    # но для полноты можно было бы описать создание таблицы заново.
    # Оставим так для простоты.
    raise ActiveRecord::IrreversibleMigration
  end
end
