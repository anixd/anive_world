# frozen_string_literal: true

class AddTranscriptionToRootsAndAffixes < ActiveRecord::Migration[7.2]
  def change
    add_column :roots, :transcription, :string
    add_column :affixes, :transcription, :string
  end
end
