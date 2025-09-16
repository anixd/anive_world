# frozen_string_literal: true

class AddCompositeUniqueIndexToPartsOfSpeech < ActiveRecord::Migration[7.2]
  def up
    remove_index :parts_of_speech, :code, name: :index_parts_of_speech_on_code
    add_index :parts_of_speech, [:code, :language_id], unique: true
  end

  def down
    remove_index :parts_of_speech, [:code, :language_id]
    add_index :parts_of_speech, :code, unique: true, name: :index_parts_of_speech_on_code
  end
end
