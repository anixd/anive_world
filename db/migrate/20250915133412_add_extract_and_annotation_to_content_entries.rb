# frozen_string_literal: true

class AddExtractAndAnnotationToContentEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :content_entries, :extract, :text
    add_column :content_entries, :annotation, :text
  end
end
