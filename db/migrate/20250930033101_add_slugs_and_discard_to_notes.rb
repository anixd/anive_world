# frozen_string_literal: true

class AddSlugsAndDiscardToNotes < ActiveRecord::Migration[7.2]
  def change
    add_column :notes, :slug, :string

    # Удаляем старый, простой индекс по author_id, если он есть, чтобы избежать дублирования
    remove_index :notes, :author_id, if_exists: true

    # Добавляем композитный уникальный индекс для :author_id и :slug.
    # Он будет действовать только для неудаленных записей (where: "discarded_at IS NULL").
    add_index :notes, [:author_id, :slug], unique: true, where: "discarded_at IS NULL"
  end
end
